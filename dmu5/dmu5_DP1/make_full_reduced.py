from astropy.table import Table,vstack
import glob
import os
import numpy as np
from astropy.time import Time
import lsst.daf.butler as dafButler

# Setting File Paths Based
BUTLER_LOC = '../../dmu4/dmu4_DP1/dmu4_DP1_ECDFS/data'
butler =  dafButler.Butler(BUTLER_LOC)
DATA = 'data'

# Finding Reduced Catalog Files
red_cats = glob.glob(DATA+'/merged/*/*/*reducedCat.fits')

# Combining Catalogs into One
full_cat = Table()
for r in red_cats:
    try:
        t= Table.read(r)
        #mask = t['VISTA_Ks_m_detect_isPatchInner'].astype('bool') & t['VISTA_Ks_m_detect_isTractInner'].astype('bool')
        full_cat=vstack([full_cat,t])
    except:
        print(r,' failed')
for c in full_cat.colnames:
    if full_cat[c].dtype=='>f8':
        m=full_cat[c]>1.e19
        full_cat[c][m]=np.nan
full_cat.write(DATA+'/full_reduced_cat_DP1_{}.fits'.format(Time.now().isot.replace('-','')[0:8]), overwrite=True)
