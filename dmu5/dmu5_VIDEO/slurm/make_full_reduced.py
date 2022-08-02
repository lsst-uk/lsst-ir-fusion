from astropy.table import Table,vstack
import glob
import os
import numpy as np
from astropy.time import Time

if os.getcwd()=='/Users/rs548/GitHub/lsst-ir-fusion/dmu5/dmu5_SXDS/slurm':
    BUTLER_LOC = '/Volumes/Raph500/lsst-ir-fusion/dmu4/dmu4_Example/data'
    DATA = '/Volumes/Raph500/lsst-ir-fusion/dmu5/dmu5_Example/data'
else:
    BUTLER_LOC = '../../../dmu4/data'
    DATA =  '../data'
#butler =  dafPersist.Butler(inputs='{}/rerun/coaddForcedPhot'.format(BUTLER_LOC))

red_cats = glob.glob(DATA+'/merged/*/*/*reducedCat.fits')

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
full_cat.write(DATA+'/full_reduced_cat_SXDS_{}.fits'.format(Time.now().isot.replace('-','')[0:8]), overwrite=True)
