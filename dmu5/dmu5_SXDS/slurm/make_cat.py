##Take an id at the command line and make the reduced cat and astropy cats on a single patch
import sys
import os
import json
import numpy as np
import lsst.daf.persistence as dafPersist
import time
import gc

from astropy.table import Table, join, vstack
import astropy.units as u

import warnings
warnings.filterwarnings("ignore")

hscBands = ['G', 'R', 'I', 'Z', 'Y']
vistaBands = ['Z', 'Y', 'J', 'H', 'Ks']
allBands = ['HSC-' +b for b in hscBands] + ['VISTA-' +b for b in vistaBands]

if os.getcwd()=='/Users/rs548/GitHub/lsst-ir-fusion/dmu5/dmu5_SXDS/slurm':
    BUTLER_LOC = '/Volumes/Raph500/lsst-ir-fusion/dmu4/dmu4_Example/data'
    DATA = '/Volumes/Raph500/lsst-ir-fusion/dmu5/dmu5_Example/data'
else:
    BUTLER_LOC = '../../../dmu4/dmu4_SXDS/data'
    DATA =  '../data'
butler =  dafPersist.Butler(inputs='{}/rerun/coaddForcedPhot'.format(BUTLER_LOC))


job_id = sys.argv[1]

def addFlux(cat, sources, photoCalib):
    """Add magnitudes and fluxes to an astropy catalogues with instrument fluxes"""
    for c in cat.colnames:
        if (c.endswith('_instFlux')):
            try:
                mags = photoCalib.instFluxToMagnitude(sources, c.replace('_instFlux',''))
                flux = photoCalib.instFluxToNanojansky(sources, c.replace('_instFlux',''))
                cat["{}_mag".format(c.replace('_instFlux',''))] = mags[:,0]
                cat["{}_mag".format(c.replace('_instFlux',''))].unit = u.mag
                cat["{}_mag".format(c.replace('_instFlux',''))].description = cat[c].description.replace(
                    'instFlux', 'mag')
                
                cat["{}_magErr".format(c.replace('_instFlux',''))] = mags[:,1]
                cat["{}_magErr".format(c.replace('_instFlux',''))].unit = u.mag
                cat["{}_magErr".format(c.replace('_instFlux',''))].description = cat[c].description.replace(
                    'instFlux', 'mag')
                
                cat["{}_flux".format(c.replace('_instFlux',''))] = flux[:,0]
                cat["{}_flux".format(c.replace('_instFlux',''))].unit = u.nJy
                cat["{}_flux".format(c.replace('_instFlux',''))].description = cat[c].description.replace(
                    'instFlux', 'flux')
                
                cat["{}_fluxErr".format(c.replace('_instFlux',''))] = flux[:,1]
                cat["{}_fluxErr".format(c.replace('_instFlux',''))].unit = u.nJy
                cat["{}_fluxErr".format(c.replace('_instFlux',''))].description = cat[c].description.replace(
                    'instFlux', 'flux')
            except:
                pass
    return cat

def makeCat(tract, patch, BUTLER_LOC,DATA=DATA,writeBandCats=True):
    """make the final catalogue on a given patch for later stacking"""
    cat =Table()
    tract = int(tract)
    for band in allBands:
        #We must keep columns under 68 characters by replacing long names
        mapping = { 
            'SecondDerivative':'SD', 
            'DoubleShapelet':'DS',
            'badCentroid':'BC',
            'badInitialCentroid':'BIC'
        }

        try:
            CoaddCalexp = butler.get('deepCoadd_calexp',  {'filter': band, 'tract': tract, 'patch': patch})
            CoaddPhotoCalib = CoaddCalexp.getPhotoCalib()
        
            measSources = butler.get('deepCoadd_meas', {'filter': band, 'tract': tract, 'patch': patch})
            measCat = measSources.asAstropy()
            measCat = addFlux(measCat, measSources, CoaddPhotoCalib)
            for c in measCat.colnames:    
                if c != 'id':
                    measCat[c].name = "{}_{}_{}".format(band,'m', c)
                
            forcedSources = butler.get('deepCoadd_forced_src', {'filter': band, 'tract': tract, 'patch': patch})
            forcedCat = forcedSources.asAstropy()
            forcedCat = addFlux(forcedCat, forcedSources, CoaddPhotoCalib)
            for c in forcedCat.colnames:    
                if c != 'id':
                    forcedCat[c].name = "{}_{}_{}".format(band,'f', c)
                    
            bandCat = join(measCat,forcedCat,join_type='outer')
            
            for c in bandCat.colnames:    
                if c != 'id':
                    newName = c
                    for k in mapping:
                        newName = newName.replace(k, mapping[k])
                    bandCat[c].name = newName
                    if len(newName)>68:
                        print('Name too long for fits writing.')
            if writeBandCats:
                bandCat.write(DATA+'/{}_{}_{}_fullCat.fits'.format(band,tract,patch), overwrite=True)
                
            if len(cat)==0:
                #On first band no join
                cat = bandCat
            else:
                #After first band join tables in
                cat = join(cat, bandCat,join_type='outer')
  
            
        except:
            warnings.warn("Band {} failed.".format(band))
                

    if len(cat) == 0:
        cat=None
    return cat.copy()

reduced_cols = [ 
    'id', 
    'VISTA-Ks_m_coord_ra', 
    'VISTA-Ks_m_coord_dec',
    'VISTA-Ks_m_detect_isPatchInner',
    'VISTA-Ks_m_detect_isTractInner'
]
for aper in ['6', '9', '12', '17']:
    reduced_cols += ['{}_m_base_CircularApertureFlux_{}_0_mag'.format(b,aper) for b in allBands]
    reduced_cols += ['{}_m_base_CircularApertureFlux_{}_0_magErr'.format(b,aper) for b in allBands]
    reduced_cols += ['{}_m_base_CircularApertureFlux_{}_0_flag'.format(b,aper) for b in allBands]
    
reduced_cols += ['{}_m_base_PsfFlux_apCorr'.format(b) for b in allBands]


#Run the patch:

job_dict=json.loads(open('../../../dmu4/dmu4_SXDS/slurm/patch_job_dict.json', 'r').read())

tract = job_dict[str(job_id)][0]
patch = job_dict[str(job_id)][1]

cat = makeCat(tract, patch, BUTLER_LOC)

intersect_red_cols =list(set(reduced_cols).intersection(set(cat.colnames)) )
cat = cat[sorted(intersect_red_cols, reverse=True)]     
cat.meta = None
cat.write(
    DATA+'/reduced_cat_{}_{}.fits'.format(tract,patch), overwrite=True
)
