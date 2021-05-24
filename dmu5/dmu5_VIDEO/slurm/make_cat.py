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
from astropy.io import ascii

import warnings
warnings.filterwarnings("ignore")

hscBands = ['G', 'R', 'I', 'Z', 'Y']
vistaBands = ['Z', 'Y', 'J', 'H', 'Ks']
allBands = ['HSC-' +b for b in hscBands] + ['VISTA-' +b for b in vistaBands]

#Allow local testing
if os.getcwd().startswith('/Users/raphaelshirley'):
    BUTLER_LOC = '../../../dmu4/dmu4_Example/data_g2'
    DATA = '../data'
else:
    BUTLER_LOC = '{}/data'.format(os.getcwd().replace('dmu5','dmu4'))
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
        CoaddPhotoCalib=None
        measCat=None
        measSources=None
        forcedCat=None
        forcedSources=None
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
                
            for c in measCat.colnames:    
                if c != 'id':
                    newName = c
                    for k in mapping:
                        newName = newName.replace(k, mapping[k])
                    measCat[c].name = newName
                    if len(newName)>68:
                        print('Name {} too long for fits writing.'.format(c))
            if writeBandCats:
                Path(DATA+'/{}/{}/{}'.format(band,tract,patch)).mkdir(
                    parents=True, exist_ok=True)
                #print(len(bandCat))
                measCat.meta=None
                measCat.sort('id')
                for c in measCat.colnames:
                    if measCat[c].dtype=='bool':
                        measCat[c]=measCat[c].astype(int)
                    measCat[c] = MaskedColumn(measCat[c])
                    measCat[c].mask = np.isnan(measCat[c]) | np.isinf(measCat[c])
                measCat['tract']=tract
                measCat['patch']=patch
                measCat['patchX']=int(patch[0])
                measCat['patchY']=int(patch[2])
                measCat.write(
                    DATA+'/{}/{}/{}/{}_{}_{}_measCat.csv'.format(
                        band,tract,patch,band,tract,patch), 
                    overwrite=True
                )

        except:
            warnings.warn("Band {} meas phot failed.".format(band))
            
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
            for c in forcedCat.colnames:    
                if c != 'id':
                    newName = c
                    for k in mapping:
                        newName = newName.replace(k, mapping[k])
                    forcedCat[c].name = newName
                    if len(newName)>68:
                        print('Name {} too long for fits writing.'.format(c))
            if writeBandCats:
                Path(DATA+'/{}/{}/{}'.format(band,tract,patch)).mkdir(
                    parents=True, exist_ok=True)
                #print(len(bandCat))
                forcedCat.meta=None
                forcedCat.sort('id')
                for c in forcedCat.colnames:
                    if forcedCat[c].dtype=='bool':
                        forcedCat[c]=forcedCat[c].astype(int)
                    forcedCat[c] = MaskedColumn(forcedCat[c])
                    forcedCat[c].mask = np.isnan(forcedCat[c]) | np.isinf(forcedCat[c])
                forcedCat['tract']=tract
                forcedCat['patch']=patch
                forcedCat['patchX']=int(patch[0])
                forcedCat['patchY']=int(patch[2])
                forcedCat.write(
                    DATA+'/{}/{}/{}/{}_{}_{}_forcedCat.csv'.format(
                        band,tract,patch,band,tract,patch), 
                    overwrite=True
                )
        except:
            warnings.warn("Band {} forced phot failed.".format(band))
            


        #make all band joins for reduced cat
        if (len(cat)==0) and (measCat is not None):
            #On first band no join
            cat = measCat
            if forcedCat is not None:
                cat = join(cat,forcedCat,join_type='outer')
        elif (measCat is not None):
            #After first band join tables in
            cols = list(measCat.colnames)
            for r in ['tract','patch']: cols.remove(r)
            cat = join(cat, measCat[cols],join_type='outer')
            if forcedCat is not None:
                cols = list(forcedCat.colnames)
                for r in ['tract','patch']: cols.remove(r)
                cat = join(cat, forcedCat[cols],join_type='outer')
  
            

                

    if len(cat) == 0:
        cat=None
    elif writeReducedCat:
        intersect_red_cols =list(set(reduced_cols).intersection(set(cat.colnames)) )
        cat = cat[sorted(intersect_red_cols, reverse=True)]     
        cat.meta = None
        Path(DATA+'/merged/{}/{}'.format(tract,patch)).mkdir(
                    parents=True, exist_ok=True)
        cat.write(
            DATA+'/merged/{}/{}/{}_{}_reducedCat.fits'.format(tract,patch,tract,patch), 
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


