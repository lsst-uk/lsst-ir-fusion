##Take an id at the command line and make the photoz input 
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


#Required if using aperture mags
oxfordApCorr = {
    'HSC_G_2as':0.1765,
    'HSC_G_3as':0.0788,
    'HSC_R_2as':0.1638,
    'HSC_R_3as':0.0905,
    'HSC_I_2as':0.1512,
    'HSC_I_3as':0.0788,
    'HSC_Z_2as':0.2155,
    'HSC_Z_3as':0.1144,
    'HSC_Y_2as':0.2023,
    'HSC_Y_3as':0.1144,
    'VIRCAM_Z_2as':0.3567,
    'VIRCAM_Z_3as':0.2023,
    'VIRCAM_Y_2as':0.3567,
    'VIRCAM_Y_3as':0.2023,
    'VIRCAM_J_2as':0.2980,
    'VIRCAM_J_3as':0.1765,
    'VIRCAM_H_2as':0.2423,
    'VIRCAM_H_3as':0.1512,
    'VIRCAM_Ks_2as':0.2288,
    'VIRCAM_Ks_3as':0.1388}

def cat_to_lephare_in(cat_name,write_loc,tract,patch):
    """Take an output patch and make a lephare input file"""
    #Open output cat
    in_cat=Table.read(cat_name)
    #
    
    #Merge the spec-z
    
    out_cat=Table()
    out_cat['Id']=in_cat['id']
    bands='grizyZYJHK'
    n=0
    context=np.full(len(out_cat),0)

    for b in bands:
        physical_filter='{}_{}'.format(
            'VIRCAM' if b.isupper() else 'HSC',b.upper().replace('K','Ks'))
        #mag_col='{}_m_base_CircularApertureFlux_6_0_mag'.format(physical_filter)
        #magerr_col=mag_col+'Err'
        flux_col='{}_m_base_CircularApertureFlux_6_0_flux'.format(physical_filter)
        fluxerr_col=flux_col+'Err'
        lepharename=b #Do we need a different filter name for lephare
        try:
            #Convert to nano jansky and then *(10**-9)*(10**-23)
            #flux,fluxerr=mag_to_flux(in_cat[mag_col],in_cat[magerr_col])
            
            out_cat[physical_filter]=in_cat[flux_col]*(10**-9)*(10**-23)
            out_cat['d_'+physical_filter]=in_cat[fluxerr_col]*(10**-9)*(10**-23)
            #Aperture corrections
            out_cat[physical_filter]*=10**(
                1*oxfordApCorr['{}_2as'.format(physical_filter)]/2.5)
            out_cat['d_'+physical_filter]*=10**(1*oxfordApCorr['{}_2as'.format(
                physical_filter)]/2.5)
            mask = np.isnan(out_cat['d_'+physical_filter]) 
            context+=~np.isnan(out_cat['d_'+physical_filter])*2**n
            
            #replace nans with -99.9
            out_cat[physical_filter]=out_cat[physical_filter].astype('float64')
            out_cat['d_'+physical_filter]=out_cat['d_'+physical_filter].astype('float64')
            
            out_cat[physical_filter][mask]=-99.9
            out_cat['d_'+physical_filter][mask]=-99.9
            
            
            #n+=1
        except KeyError:
            print('VISTA Error: band {} missing on tract {} and patch {}.'.format(
                b,tract,patch))
            out_cat[physical_filter]=np.full(len(out_cat),-99.9,dtype='float64')
            out_cat['d_'+physical_filter]=np.full(len(out_cat),-99.9,dtype='float64')
            context+=~np.isclose(out_cat['d_'+physical_filter],-99.9)*2**n
        n+=1
    out_cat['context']=context
    out_cat['z-spec']=np.full(len(out_cat),-99.9)#np.nan)
    #Write the input catalogue
    Path('../data/{}/{}'.format(tract,patch)).mkdir(
                    parents=True, exist_ok=True)
    out_cat.write(write_loc, format='ascii.commented_header',overwrite=True)
    return out_cat



#Run the patch:
job_id = sys.argv[1]
patch_dict = sys.argv[2]
job_dict=json.loads(open(
    patch_dict, 
    'r'
).read())

tract = job_dict[str(job_id)][0]
patch = job_dict[str(job_id)][1]
tract = int(tract)
patchX=int(patch[0])
patchY=int(patch[2])
patch=patchX+9*patchY
print('Running tract {} patch {}'.format(tract,patch))
cat_name='../../../dmu5/dmu5_VIDEO/data/merged/{}/{}/{}_{}_reducedCat.fits'.format(
    tract,patch,tract,patch)
write_loc='../data/{}/{}/photoz.in'.format(tract,patch)
cat=cat_to_lephare_in(cat_name,write_loc,tract,patch)

if job_id==0:
    cols = Table()
    cols['name'] = cat.colnames
    cols['description'] = [cat[c].description for c in cat.colnames]
    cols['unit'] = [str(cat[c].unit) for c in cat.colnames]
    cols['type'] = [cat[c].dtype for c in cat.colnames]
    cols.write('../data/columns_descriptions.csv',overwrite=True)
