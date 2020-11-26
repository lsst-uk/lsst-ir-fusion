#!/bin/bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
#source /Users/rs548/GitHub/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
mkdir data
echo "lsst.obs.vista.VistaMapper" > ./data/_mapper 
mkdir -p ../data/ref_cats/ps1_pv3_3pi_20170110_vhs_vista
cp ../../../dmu2/data/refcat_vhs_vista_ingested/ref_cats/cal_ref_cat/* ../data/ref_cats/ps1_pv3_3pi_20170110_vhs_vista
mkdir -p ../data/rerun/processCcdOutputs/coadd
makeSkyMap.py ../data --rerun processCcdOutputs:coadd --clobber-config