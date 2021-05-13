#!/bin/bash
#source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack_v21/loadLSST.bash
#source /Users/rs548/GitHub/lsst_stack/loadLSST.bash
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
mkdir ../data
echo "lsst.obs.vista.VistaMapper" > ../data/_mapper 
mkdir -p ../data/ref_cats/ps1_pv3_3pi_20170110_vista
cp ../../../dmu2/data/ref_cats_viking_ingested/ref_cats/cal_ref_cat/* ../data/ref_cats/ps1_pv3_3pi_20170110_vista
#We must run a single file to setup the rerun for the skymap creation
ingestImages.py ../data /home/ir-shir1/rds/rds-iris-ip005/data/private/VISTA/VIKING/20100121/v20100121_00140_st.fit --ignore-ingested 
processCcd.py ../data --rerun processCcdOutputs --id dateObs=2010-01-21 numObs=00140 ccd=0
makeSkyMap.py ../data --rerun processCcdOutputs:coadd 
