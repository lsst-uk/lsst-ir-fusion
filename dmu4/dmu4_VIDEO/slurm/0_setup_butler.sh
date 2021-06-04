#!/bin/bash
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
#source /Users/rs548/GitHub/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
mkdir ../data
echo "lsst.obs.vista.VistaMapper" > ../data/_mapper 
mkdir -p ../data/ref_cats/ps1_pv3_3pi_20170110_vista
cp ../../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat/* ../data/ref_cats/ps1_pv3_3pi_20170110_vista
#We must run a single file to setup the rerun for the skymap creation
#ingestImages.py ../data /home/ir-shir1/rds/rds-iris-ip005/data/private/VISTA/VIDEO/20171027/v20171027_00133_st.fit --ignore-ingested 
processCcd.py ../data --rerun processCcdOutputs --id dateObs=2017-10-27 numObs=00133 ccd=0
makeSkyMap.py ../data --rerun processCcdOutputs:coadd 
