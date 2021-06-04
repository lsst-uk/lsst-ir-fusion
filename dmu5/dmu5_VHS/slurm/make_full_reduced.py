from astropy.table import Table,vstack
#import glob
import os
import json
import sys

BUTLER_LOC = os.getcwd().replace('dmu5','dmu4')+'/data'
DATA = '../data'

patch_dict_filename=sys.argv[1]
#red_cats = glob.glob(DATA+'/reduced*.fits')
patch_dict = json.load(open(patch_dict_filename,'r+'))

full_cat = Table()
for i in patch_dict:
    tract=patch_dict[i][0]
    patch=patch_dict[i][1]
    try:
        t= Table.read(DATA+'/merged/{tract}/{patch}/{tract}_{patch}_reducedCat.fits'.format(
            tract=tract,
            patch=patch
        ))
        mask = (t['VISTA_Ks_m_detect_isPatchInner'].astype('bool') 
                & t['VISTA_Ks_m_detect_isTractInner'].astype('bool'))
        full_cat=vstack([full_cat,t[mask]])
    except:
        print(i,' failed')
        
full_filename=patch_dict_filename.split('/')[-1].split('.')[0].replace(
    'patch_job_dict','full_reduced_cat') +'.fits'
full_cat.write(DATA+'/'+full_filename, overwrite=True)
