#!/bin/bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack_v21/loadLSST.bash
#source /Users/rs548/GitHub/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
mkdir ../data
echo "lsst.obs.vista.VistaMapper" > ../data/_mapper 
mkdir -p ../data/ref_cats/ps1_pv3_3pi_20170110_vhs_vista
cp ../../../dmu2/data/ref_cats_vhs_ingested/ref_cats/cal_ref_cat/* ../data/ref_cats/ps1_pv3_3pi_20170110_vista
#We must run a single file to setup the rerun for the skymap creation
ingestImages.py ../data /home/ir-shir1/rds/rds-iris-ip005/data/private/VISTA/VHS/20091205/v20091205_00224_st.fit --ignore-ingested --clobber-config
processCcd.py ../data --rerun processCcdOutputs --id dateObs=2009-12-05 numObs=00224 --clobber-config
makeSkyMap.py ../data --rerun processCcdOutputs:coadd --clobber-config
