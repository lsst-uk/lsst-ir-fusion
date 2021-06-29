#!/bin/bash
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
source /Users/raphaelshirley/Documents/github/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista 21.0.0-2

rm -r data
butler create data
butler register-instrument data lsst.obs.vista.VIRCAM


# Import the reference catalogues to the butler.
butler import data "${PWD}/../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat" --export-file "${PWD}/../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat/export.yaml" --skip-dimensions instrument,physical_filter,detector

butler ingest-raws data ../../dmu0/dmu0_VISTA/dmu0_VIDEO/data/*/*_st.fit
butler define-visits data lsst.obs.vista.VIRCAM --collections VIRCAM/raw/all


pipetask run -d "exposure=622538" -b data/butler.yaml --input VIRCAM/raw/all --register-dataset-types -p _SingleFrame.yaml --instrument lsst.obs.vista.VIRCAM --output-run demo_collection 
#use --extend-run if rerunning
#pipetask run -d "exposure=622538" -b data/butler.yaml --input VIRCAM/raw/all --register-dataset-types -p "${PIPE_TASKS_DIR}/pipelines/DRP.yaml#singleFrame" --instrument lsst.obs.vista.VIRCAM --output-run demo_collection


#export TRACTS=8524 
#export PATCHES=3,5

#makeSkyMap.py 
#pipetask run

#coaddDriver??
#pipetask run 

#multiBandDriver??
#pipetask run

