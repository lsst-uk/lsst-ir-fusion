##Take an id at the command line and make the reduced cat and astropy cats on a single 
#patch
import sys
import os
from pathlib import Path
import json
import numpy as np
import lsst.daf.persistence as dafPersist
import time
import gc

from astropy.table import Table, join, vstack, MaskedColumn
import astropy.units as u

import warnings
warnings.filterwarnings("ignore")

hscBands = ['G', 'R', 'I', 'Z', 'Y']
vistaBands = ['Z', 'Y', 'J', 'H', 'Ks']
allBands = ['HSC-' +b for b in hscBands] + ['VISTA-' +b for b in vistaBands]

#Allow local testing
if os.getcwd()=='/Users/raphaelshirley/Documents/github/'\
        'lsst-ir-fusion/dmu5/dmu5_VIKING/slurm':
    BUTLER_LOC = '../../../dmu4/dmu4_Example/data'
    DATA = '../data'
else:
    BUTLER_LOC = '../../../dmu4/dmu4_VIKING/data'
    DATA =  '../data'
butler =  dafPersist.Butler(inputs='{}/rerun/coaddPhot'.format(BUTLER_LOC))


job_id = sys.argv[1]
patch_dict = sys.argv[2]

#Set columns to go in a 'reduced catalogue' for sharing.
reduced_cols = [ 
    'id', 
    'VISTA_Ks_f_coord_ra', 
    'VISTA_Ks_f_coord_dec',
    'VISTA_Ks_f_detect_isPatchInner',
    'VISTA_Ks_f_detect_isTractInner'
]
for aper in ['6', '9', '12', '17']:
    reduced_cols += [
        '{}_f_base_CircularApertureFlux_{}_0_mag'.format(b,aper) for b in allBands
    ]
    reduced_cols += [
        '{}_f_base_CircularApertureFlux_{}_0_magErr'.format(b,aper) for b in allBands
    ]
    #reduced_cols += [
    #    '{}_f_base_CircularApertureFlux_{}_0_flag'.format(b,aper) for b in allBands
    #]
    
reduced_cols += ['{}_f_base_PsfFlux_mag'.format(b) for b in allBands]
reduced_cols += ['{}_f_base_PsfFlux_magErr'.format(b) for b in allBands]

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

def makeCat(tract, patch, BUTLER_LOC,DATA=DATA,writeBandCats=True,writeReducedCat=False):
    """make the final catalogue on a given patch for ingestion to a database"""
    cat =Table()
    tract = int(tract)
    for band in allBands:
        #We must keep columns under 68 characters by replacing long names
        mapping = { 
            'SecondDerivative':'SD', 
            'DoubleShapelet':'DS',
            'badCentroid':'BC',
            'badInitialCentroid':'BIC',
            'sincCoeffsTruncated':'SCT',
        }

        try:
            CoaddCalexp = butler.get(
                'deepCoadd_calexp',  
                {'filter': band, 'tract': tract, 'patch': patch}
            )
            CoaddPhotoCalib = CoaddCalexp.getPhotoCalib()
        
            measSources = butler.get(
                'deepCoadd_meas', 
                {'filter': band, 'tract': tract, 'patch': patch}
            )
            measCat = measSources.asAstropy()
            measCat = addFlux(measCat, measSources, CoaddPhotoCalib)
            for c in measCat.colnames:    
                if c != 'id':
                    measCat[c].name = "{}_{}_{}".format(band.replace('-','_'),'m', c)
                
            bandCat = measCat
            
            try:
                forcedSources = butler.get(
                    'deepCoadd_forced_src', 
                    {'filter': band, 'tract': tract, 'patch': patch}
                )
                forcedCat = forcedSources.asAstropy()
                forcedCat = addFlux(forcedCat, forcedSources, CoaddPhotoCalib)
                for c in forcedCat.colnames:    
                    if c != 'id':
                        forcedCat[c].name = "{}_{}_{}".format(band,'f', c)
                    
                bandCat = join(bandCat,forcedCat,join_type='outer')
            except:
                warnings.warn("Band {} forced phot failed.".format(band))
            
            for c in bandCat.colnames:    
                if c != 'id':
                    newName = c
                    for k in mapping:
                        newName = newName.replace(k, mapping[k])
                    bandCat[c].name = newName
                    if len(newName)>68:
                        print('Name {} too long for fits writing.'.format(c))
            if writeBandCats:
                Path(DATA+'/{}/{}/{}'.format(band,tract,patch)).mkdir(
                    parents=True, exist_ok=True)
                #print(len(bandCat))
                bandCat.meta=None
                bandCat.sort('id')
                for c in bandCat.colnames:
                    bandCat[c] = MaskedColumn(bandCat[c])
                    bandCat[c].mask = np.isnan(bandCat[c]) | np.isinf(bandCat[c])
                bandCat['tract']=tract
                bandCat['patch']=patch
                bandCat.write(
                    DATA+'/{}/{}/{}/{}_{}_{}_mergedCat.csv'.format(
                        band,tract,patch,band,tract,patch), 
                    overwrite=True
                )
                #forcedCat.write(
                #    DATA+'/{}/{}/{}/{}_{}_{}_forcedCat.csv'.format(
                #        band,tract,patch,band,tract,patch), 
                #    overwrite=True
                #)
                
            if len(cat)==0:
                #On first band no join
                cat = bandCat
            else:
                #After first band join tables in
                cols = list(bandCat.colnames)
                for r in ['tract','patch']: cols.remove(r)
                cat = join(cat, bandCat[cols],join_type='outer')
  
            
        except:
            warnings.warn("Band {} failed.".format(band))
                

    if len(cat) == 0:
        cat=None
    elif writeReducedCat:
        intersect_red_cols =list(set(reduced_cols).intersection(set(cat.colnames)) )
        cat = cat[sorted(intersect_red_cols, reverse=True)]     
        cat.meta = None
        Path(DATA+'/merged/{}/{}'.format(tract,patch)).mkdir(
                    parents=True, exist_ok=True)
        cat.write(
            DATA+'/merged/{}/{}/{}_{}_reduced_cat.fits'.format(tract,patch,tract,patch), 
            overwrite=True
        )
    return cat



#Run the patch:

job_dict=json.loads(open(
    patch_dict, 
    'r'
).read())

tract = job_dict[str(job_id)][0]
patch = job_dict[str(job_id)][1]

cat = makeCat(tract, patch, BUTLER_LOC)


