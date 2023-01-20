from astropy.table import Table,vstack
import glob
import os
import numpy as np
from astropy.time import Time


red_cats = glob.glob(../data/*/*/*.out')

full_cat = Table()
for r in red_cats:
    try:
        t= Table.read(
        r,format='ascii.commented_header',
        header_start=48,data_start=49,delimiter='\s')
        full_cat=vstack([full_cat,t])
    except:
        print(r,' failed')
for c in full_cat.colnames:
    if full_cat[c].dtype=='>f8':
        m=full_cat[c]>1.e19
        full_cat[c][m]=np.nan
full_cat.write('../data/full_reduced_cat_SXDS_{}.fits'.format(
    Time.now().isot.replace('-','')[0:8]), overwrite=True)
