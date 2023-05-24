##Take an id at the command line and make the reduced cat and astropy cats on a single 
#patch
import sys
import os
from pathlib import Path
import json
import numpy as np
#import lsst.daf.persistence as dafPersist
import lsst.daf.butler as dafButler
import time
import gc

from astropy.table import Table, join, vstack, MaskedColumn
import astropy.units as u
from astropy.io import ascii
import itertools
import warnings
warnings.filterwarnings("ignore")

hscBands = ['G', 'R', 'I', 'Z', 'Y']
vistaBands = ['Z', 'Y', 'J', 'H', 'Ks']
allBands = ['HSC_' +b for b in hscBands] + ['VIRCAM_' +b for b in vistaBands]

#Allow local testing
if os.getcwd().startswith('/Users/raphaelshirley'):
    BUTLER_LOC = '../../../dmu4/dmu4_Example/data'
    DATA = '../data'
    COLLECTION='u/ir-shir1/DRP/multiVisitLater'
else:
    #BUTLER_LOC = os.getcwd().replace('dmu5/dmu5_VIDEO/slurm','dmu4/data')
    BUTLER_LOC ='/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/data'
    #DATA =  '../data'
    DATA = '/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/csv/viking'
    COLLECTION='u/ir-shir1/DRP/vikingMultiVisit' #/20221204T111133Z'
butler =  dafButler.Butler(BUTLER_LOC)


job_id = sys.argv[1]
patch_dict = sys.argv[2]

#Set columns to go in a 'reduced catalogue' for sharing.
reduced_cols = [ 
    'id', 
    'VIRCAM_Ks_m_coord_ra', 
    'VIRCAM_Ks_m_coord_dec',
    'HSC_R_m_coord_ra',
    'HSC_R_m_coord_dec',
    'VIRCAM_Ks_m_detect_isPatchInner',
    'VIRCAM_Ks_m_detect_isTractInner',
    'VIRCAM_Ks_m_detect_isPrimary',
    'VIRCAM_Ks_m_deblend_nChild',
    'VIRCAM_Ks_m_merge_peak_sky',
    #'VISTA_Ks_m_base_ClassificationExtendedness_value',
    #'VISTA_Ks_m_base_ClassificationExtendedness_flag',
]

    
colTypes=[
    '{}_m_base_CircularApertureFlux_6_0_{}',
    #'{}_m_base_PsfFlux_{}',
    #'{}_m_slot_ModelFlux_{}',
    '{}_m_base_ClassificationExtendedness_value',
    '{}_m_base_ClassificationExtendedness_flag',
]
measTypes=['mag', 'magErr', 'flux', 'fluxErr', 'flag']
for c,b,m in itertools.product(colTypes,allBands,measTypes):
    reduced_cols+=[c.format(b.replace('-','_'),m)]


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

def makeCat(tract, patch, BUTLER_LOC,DATA=DATA,writeBandCats=True,writeReducedCat=True):
    """make the final catalogue on a given patch for ingestion to a database"""
    cat =Table()
    tract = int(tract)
    patchX=int(patch[0])
    patchY=int(patch[2])
    patch=patchX+9*patchY
    print('Running tract {} patch {}'.format(tract,patch))
    for band in allBands:
        bandType=band.split('_')[1][0]
        if 'HSC' in band:
            bandType=bandType.lower()
        #We must keep columns under 68 characters by replacing long names
        mapping = { 
            'SecondDerivative':'SD', 
            'DoubleShapelet':'DS',
            'badCentroid':'BC',
            'badInitialCentroid':'BIC',
            'sincCoeffsTruncated':'SCT',
            'apertureTruncated':'AT',
            'SourceMomentsRound':'SMR',
            'photometryKron':'photKron',
        }
        #replace ambiguous case sensitive bands with physical filter
        for s in 'grizyZYJHK':
            inst='HSC_'
            if s.isupper():
                inst='VIRCAM_'
            mapping['footprint_{}'.format(s)]='footprint_'+inst+s
            mapping['peak_{}'.format(s)]='peak_'+inst+s

        CoaddPhotoCalib=None
        measCat=None
        measSources=None
        forcedCat=None
        forcedSources=None
        try:
            #print(band,bandType,tract,patch)
            CoaddCalexp = butler.get(
                'deepCoadd_calexp',  
                {'band': bandType, 'tract': tract, 'patch': patch, 'skymap':'hscPdr2'},
                collections=COLLECTION
            )
            CoaddPhotoCalib = CoaddCalexp.getPhotoCalib()
            #print('Got photo calib')    
            measSources = butler.get(
                'deepCoadd_meas', 
                {'band': bandType, 'tract': tract, 'patch': patch, 'skymap':'hscPdr2'},
                collections=COLLECTION
            )
            #print('Got meas cat')
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
                #print('preloop')
                for c in measCat.colnames:
                    #print(c)
                    if measCat[c].dtype=='bool':
                        measCat[c]=measCat[c].astype(int)
                        #print('bool if')
                    if (measCat[c].dtype==np.dtype('float64')) and ('coord' not in c):
                        measCat[c] = MaskedColumn(measCat[c])
                        measCat[c].mask = np.isnan(measCat[c]) | np.isinf(measCat[c])
                        measCat[c]=measCat[c].astype('float32')
                    if 'coord' in c:
                        measCat[c].convert_unit_to(u.deg)
                    #print('pre mask')
                    #measCat[c] = MaskedColumn(measCat[c])
                    #measCat[c].mask = np.isnan(measCat[c]) | np.isinf(measCat[c])
                    #print(c)
                #print('postloop')
                measCat['tract']=tract
                measCat['patch']=patch
                #measCat['patchX']=patchX
                #measCat['patchY']=patchY
                #print('prewrite:', tract,'/',patch)
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
                {'band': bandType, 'tract': tract, 'patch': patch,'skymap':'hscPdr2'},
                collections=COLLECTION
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
                    if (forcedCat[c].dtype==np.dtype('float64')) and ('coord' not in c):
                        forcedCat[c]=forcedCat[c].astype('float32')
                    if 'coord' in c:
                        forcedCat[c].convert_unit_to(u.deg)
                    #forcedCat[c] = MaskedColumn(forcedCat[c])
                    #forcedCat[c].mask = np.isnan(forcedCat[c]) | np.isinf(measCat[c])
                forcedCat['tract']=tract
                forcedCat['patch']=patch
                #forcedCat['patchX']=patchX
                #forcedCat['patchY']=patchY
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
                cols=list(forcedCat.colnames)
                for r in ['tract','patch']: cols.remove(r)
                cat = join(cat,forcedCat,join_type='left')
        elif (measCat is not None):
            #After first band join tables in
            cols = list(measCat.colnames)
            for r in ['tract','patch']: cols.remove(r)
            cat = join(cat, measCat[cols],join_type='left')
            if forcedCat is not None:
                cols = list(forcedCat.colnames)
                for r in ['tract','patch']: cols.remove(r)
                cat = join(cat, forcedCat[cols],join_type='left')
  
            

                

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
        cat.write(
            DATA+'/merged/{}/{}/{}_{}_reducedCat.csv'.format(tract,patch,tract,patch),
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
#print('Running tract {} patch {}'.format(tract,patch))
cat = makeCat(tract, patch, BUTLER_LOC)

if job_id==0:
    cols = Table()
    cols['name'] = cat.colnames
    cols['description'] = [cat[c].description for c in cat.colnames]
    cols['unit'] = [str(cat[c].unit) for c in cat.colnames]
    cols['type'] = [cat[c].dtype for c in cat.colnames]
    cols.write('./columns_descriptions.csv',overwrite=True)
