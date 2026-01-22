import sys
import os
from pathlib import Path
import json
import numpy as np
import lsst.daf.butler as dafButler
import warnings
import itertools
from astropy.table import Table, join, MaskedColumn
import astropy.units as u
warnings.filterwarnings("ignore")

# Define bands
comcamBands = ['u', 'g', 'r', 'i', 'z', 'y']
vistaBands = ['Z', 'Y', 'J', 'H', 'K']
allBands = ['ComCam_' + b for b in comcamBands] + ['VIRCAM_' + b for b in vistaBands]

# Set up paths

BUTLER_LOC = '../../dmu4/dmu4_DP1/dmu4_DP1_ECDFS/data'
DATA = 'data'
COLL_MEAS_FORCED = "u/ir-sare1/DRP/videoMultiVisit/20260119T222850Z"
COLL_CALEXP_VIRCAM = "u/ir-sare1/DRP/videoCoaddDetects/20260119T111844Z"
COLL_CALEXP_COMCAM = "ComCam/deepCoadd_results"


# Init Butler
butler = dafButler.Butler(BUTLER_LOC)

# Command-line args
job_id = sys.argv[1]
patch_dict = sys.argv[2]

# Reduced catalog columns
reduced_cols = [
    'id', 'VIRCAM_Ks_m_coord_ra', 'VIRCAM_Ks_m_coord_dec',
    'comcam_R_m_coord_ra', 'comcam_R_m_coord_dec',
    'VIRCAM_Ks_m_detect_isPatchInner', 'VIRCAM_Ks_m_detect_isTractInner',
    'VIRCAM_Ks_m_detect_isPrimary', 'VIRCAM_Ks_m_deblend_nChild',
    'VIRCAM_Ks_m_merge_peak_sky',
]

colTypes = [
    '{}_m_base_CircularApertureFlux_6_0_{}',
    '{}_m_base_ClassificationExtendedness_value',
    '{}_m_base_ClassificationExtendedness_flag',
]

measTypes = ['mag', 'magErr', 'flux', 'fluxErr', 'flag']
for c, b, m in itertools.product(colTypes, allBands, measTypes):
    reduced_cols.append(c.format(b.replace('-', '_'), m))


def addFlux(cat, sources, photoCalib):
    """Add magnitudes and fluxes to an astropy catalogues with instrument fluxes"""
    for c in cat.colnames:
        if (c.endswith('_instFlux')):
            try:
                mags = photoCalib.instFluxToMagnitude(sources, c.replace('_instFlux',''))
                flux = photoCalib.instFluxToNanojansky(sources, c.replace('_instFlux',''))
                cat["{}_mag".format(c.replace('_instFlux',''))] = mags[:,0]
                cat["{}_mag".format(c.replace('_instFlux',''))].unit = u.mag
                cat[
                    "{}_mag".format(c.replace('_instFlux',''))
                ].description = cat[c].description.replace('instFlux', 'mag')
                
                cat["{}_magErr".format(c.replace('_instFlux',''))] = mags[:,1]
                cat["{}_magErr".format(c.replace('_instFlux',''))].unit = u.mag
                cat[
                    "{}_magErr".format(c.replace('_instFlux',''))
                ].description = cat[c].description.replace('instFlux', 'mag')
                
                cat["{}_flux".format(c.replace('_instFlux',''))] = flux[:,0]
                cat["{}_flux".format(c.replace('_instFlux',''))].unit = u.nJy
                cat[
                    "{}_flux".format(c.replace('_instFlux',''))
                ].description = cat[c].description.replace('instFlux', 'flux')
                
                cat["{}_fluxErr".format(c.replace('_instFlux',''))] = flux[:,1]
                cat["{}_fluxErr".format(c.replace('_instFlux',''))].unit = u.nJy
                cat[
                    "{}_fluxErr".format(c.replace('_instFlux',''))
                ].description = cat[c].description.replace('instFlux', 'flux')
            except:
                pass
    return cat


def makeCat(tract, patch_input, BUTLER_LOC, DATA=DATA,
            writeBandCats=True, writeReducedCat=True, writeSchema=False):
    """make the final catalogue on a given patch for ingestion to a database"""
    print(f"\n[START] Tract: {tract}, Raw patch input: {patch_input}")

   
    # PATCH PARSING (supports int patch directly)
    try:
        if isinstance(patch_input, (int, np.integer)):
            patch_id = int(patch_input)
            patchX = patch_id % 10
            patchY = patch_id // 10
        elif isinstance(patch_input, str) and "," in patch_input:
            patchX, patchY = map(int, patch_input.split(","))
            patch_id = patchX + 10 * patchY
        elif isinstance(patch_input, (list, tuple)):
            patchX, patchY = patch_input
            patch_id = patchX + 10 * patchY
        else:
            raise ValueError(f"Unrecognized patch format: {patch_input}")
    except Exception as e:
        print(f"[ERROR] Could not parse patch: {e}")
        return None

    tract = int(tract)
    print(f"[PARSED] tract={tract}, patchX={patchX}, patchY={patchY}, patch_id={patch_id}")

    cat = Table()

    for band in allBands:
        bandType = band.split('_')[1][0]
        if 'ComCam' in band:
            bandType = bandType.lower()

        print(f"\n[INFO] Processing band: {band}, bandType: {bandType}")

        # Initialize containers
        measCat = None
        forcedCat = None

        try:
            print(f"  → Fetching CoaddCalexp...")
            calexp_collection = COLL_CALEXP_COMCAM if band.startswith("ComCam_") else COLL_CALEXP_VIRCAM
            CoaddCalexp = butler.get('deepCoadd_calexp',
                                     {'band': bandType, 'tract': tract, 'patch': patch_id, 'skymap': 'lsst_cells_v1'},
                                     collections=calexp_collection)
            CoaddPhotoCalib = CoaddCalexp.getPhotoCalib()
            print("    ✓ Got CoaddCalexp and PhotoCalib.")

            print(f"  → Fetching measSources...")
            measSources = butler.get('deepCoadd_meas',
                                     {'band': bandType, 'tract': tract, 'patch': patch_id, 'skymap': 'lsst_cells_v1'},
                                     collections=COLL_MEAS_FORCED)
            print(f"    ✓ Got measSources: {len(measSources)} entries")

            measCat = measSources.asAstropy()
            print(f"    ✓ Converted measSources to Astropy table: {len(measCat)} rows")

            measCat = addFlux(measCat, measSources, CoaddPhotoCalib)

            for c in measCat.colnames:
                if c != 'id':
                    measCat[c].name = f"{band.replace('-', '_')}_m_{c}"

            if writeBandCats and len(measCat) > 0:
                path = Path(DATA) / band / str(tract) / str(patch_id)
                path.mkdir(parents=True, exist_ok=True)
                measCat['tract'] = tract
                measCat['patch'] = patch_id
                measCat.meta = None
                measCat.sort('id')
                print(f"  → Writing measCat to {path / f'{band}_{tract}_{patch_id}_measCat.csv'}")
                measCat.write(path / f'{band}_{tract}_{patch_id}_measCat.csv', overwrite=True)
            else:
                print(f"  [SKIP] measCat write skipped: writeBandCats={writeBandCats}, len={len(measCat)}")

        except Exception as e:
            print(f"[WARN] Band {band} meas phot failed: {e}")

        try:
            print(f"  → Fetching forcedSources...")
            forcedSources = butler.get('deepCoadd_forced_src',
                                       {'band': bandType, 'tract': tract, 'patch': patch_id, 'skymap': 'lsst_cells_v1'},
                                       collections=COLL_MEAS_FORCED)
            print(f"    ✓ Got forcedSources: {len(forcedSources)} entries")

            forcedCat = forcedSources.asAstropy()
            print(f"    ✓ Converted forcedSources to Astropy table: {len(forcedCat)} rows")

            forcedCat = addFlux(forcedCat, forcedSources, CoaddPhotoCalib)

            for c in forcedCat.colnames:
                if c != 'id':
                    forcedCat[c].name = f"{band}_f_{c}"

            if writeBandCats and len(forcedCat) > 0:
                path = Path(DATA) / band / str(tract) / str(patch_id)
                path.mkdir(parents=True, exist_ok=True)
                forcedCat['tract'] = tract
                forcedCat['patch'] = patch_id
                forcedCat.meta = None
                forcedCat.sort('id')
                print(f"  → Writing forcedCat to {path / f'{band}_{tract}_{patch_id}_forcedCat.csv'}")
                forcedCat.write(path / f'{band}_{tract}_{patch_id}_forcedCat.csv', overwrite=True)
            else:
                print(f"  [SKIP] forcedCat write skipped: writeBandCats={writeBandCats}, len={len(forcedCat)}")

        except Exception as e:
            print(f"[WARN] Band {band} forced phot failed: {e}")

        # Join logic (unchanged for now)
        if (len(cat) == 0) and (measCat is not None):
            cat = measCat
            if forcedCat is not None:
                cat = join(cat, forcedCat, join_type='left')
        elif measCat is not None:
            cat = join(cat, measCat, join_type='left')
            if forcedCat is not None:
                cat = join(cat, forcedCat, join_type='left')

    if len(cat) == 0:
        print("[INFO] Final catalog is empty. Returning None.")
        return None

    if writeReducedCat:
        intersect_red_cols = list(set(reduced_cols).intersection(cat.colnames))
        cat = cat[sorted(intersect_red_cols, reverse=True)]
        cat.meta = None
        red_path = Path(DATA) / 'merged' / str(tract) / str(patch_id)
        red_path.mkdir(parents=True, exist_ok=True)
        print(f"\n→ Writing reducedCat to {red_path}")
        cat.write(red_path / f"{tract}_{patch_id}_reducedCat.fits", overwrite=True)
        cat.write(red_path / f"{tract}_{patch_id}_reducedCat.csv", overwrite=True)

    print(f"[DONE] makeCat complete for tract={tract}, patch={patch_id}")
    return cat


# Run patch
job_dict = json.loads(open(patch_dict, 'r').read())
tract = job_dict[str(job_id)][0]
patch = job_dict[str(job_id)][1]
writeSchema = int(job_id) == 0

cat = makeCat(tract, patch, BUTLER_LOC, writeSchema=writeSchema)

# Write column info
if writeSchema and cat is not None:
    cols = Table()
    cols['name'] = cat.colnames
    cols['description'] = [cat[c].description if hasattr(cat[c], 'description') else '' for c in cat.colnames]
    cols['unit'] = [str(cat[c].unit) if hasattr(cat[c], 'unit') else '' for c in cat.colnames]
    cols['type'] = [cat[c].dtype for c in cat.colnames]
    cols.write('./columns_descriptions.csv', overwrite=True)

