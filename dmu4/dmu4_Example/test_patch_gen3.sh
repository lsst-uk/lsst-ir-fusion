#!/bin/bash
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
#source /Users/raphaelshirley/Documents/github/lsst-stack/loadLSST.bash
source /Users/raphaelshirley/Documents/github/stack22/loadLSST.bash
setup obs_vista 22.0.0-2
setup lsst_distrib -t w_latest
#setup lsst_apps -t w_latest

export repo=data
#export TRACTS=8524 
#export PATCHES=3,5

# This should already be set, but doesn't harm to make sure:
export DYLD_LIBRARY_PATH=${LSST_LIBRARY_PATH}
export OBS_VISTA=/Users/raphaelshirley/Documents/github/stack22/stack/current/DarwinX86/obs_vista/22.0.0-2

rm -r $repo
butler create $repo
butler register-instrument $repo lsst.obs.vista.VIRCAM
#Make and register the all sky skymap using local config file
butler register-skymap $repo -C makeSkyMap.py
# Import the reference catalogues to the butler.
butler import $repo "${PWD}/../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat" --export-file "${PWD}/../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat/export.yaml" --skip-dimensions instrument,physical_filter,detector
#Ingest the raw exposures
butler ingest-raws $repo ../../dmu0/dmu0_VISTA/dmu0_VIDEO/data/*/*_st.fit 
#Define the visits from the ingested exposures
butler define-visits $repo VIRCAM #--collections VIRCAM/raw/all
#We don't have calibs but we need the collection for later processing
butler write-curated-calibrations data VIRCAM

#Run processCcd on some exposures
#AND (exposure=658653 OR exposure=642039)
pipetask run -d "(detector=10 or detector=9) AND physical_filter='VIRCAM-Ks'" -b $repo --input VIRCAM/raw/all,refcats,VIRCAM/calib --register-dataset-types -p './DRP.yaml#processCcd' --instrument lsst.obs.vista.VIRCAM  --output-run processCcdOutputs  

#Coadd the exposures
pipetask run -b $repo --input processCcdOutputs --input skymaps --input  VIRCAM/raw/all,refcats,VIRCAM/calib  --register-dataset-types -p "./DRP.yaml#coaddition" --instrument lsst.obs.vista.VIRCAM --output-run coadd --debug
#Run photometry pipeline
pipetask run -b $repo --input processCcdOutputs --input  VIRCAM/raw/all,refcats,VIRCAM/calib --input skymaps --input coadd --register-dataset-types -p "./DRP.yaml#multiband" --instrument lsst.obs.vista.VIRCAM --output-run photo --debug




