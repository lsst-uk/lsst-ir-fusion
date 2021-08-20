#!/bin/bash
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
#source /Users/raphaelshirley/Documents/github/lsst-stack/loadLSST.bash
source /Users/raphaelshirley/Documents/github/stack22/loadLSST.bash
setup lsst_distrib
setup obs_vista 22.0.0-2
export repo=data
#export TRACTS=8524 
#export PATCHES=3,5

# This should already be set, but doesn't harm to make sure:
export DYLD_LIBRARY_PATH=${LSST_LIBRARY_PATH}

rm -r $repo
butler create $repo
butler register-instrument $repo lsst.obs.vista.VIRCAM


# Import the reference catalogues to the butler.
butler import $repo "${PWD}/../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat" --export-file "${PWD}/../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat/export.yaml" --skip-dimensions instrument,physical_filter,detector

#Ingest the raw exposures
butler ingest-raws $repo ../../dmu0/dmu0_VISTA/dmu0_VIDEO/data/*/*_st.fit 
#Define the visits from the ingested exposures
butler define-visits $repo VIRCAM #--collections VIRCAM/raw/all
#We don't have calibs but we need the collection for later processing
butler write-curated-calibrations data VIRCAM

#pipetask run -b $repo/butler.yaml --input VIRCAM/raw/all,refcats --register-dataset-types -p "${PIPE_TASKS_DIR}/pipelines/DRP.yaml"#processCcd --instrument lsst.obs.vista.VIRCAM --output-run demo_collection 

#processCcd_SingleFrame.yaml
#use --extend-run if rerunning 
#pipetask run -d "exposure=622538" -b data/butler.yaml --input VIRCAM/raw/all,refcats,VIRCAM/calib/unbounded --register-dataset-types -p "${PIPE_TASKS_DIR}/pipelines/DRP.yaml#singleFrame" --instrument lsst.obs.vista.VIRCAM --output-run processCcdOutputs
#pipetask run -d "exposure=622538" -b data/butler.yaml --input VIRCAM/raw/all,refcats,VIRCAM/calib/unbounded --register-dataset-types -p _SingleFrame.yaml --instrument VIRCAM --output-run processCcdOutputs
pipetask run -d "(detector=9 OR detector=10) AND physical_filter='VIRCAM-Ks'" -b $repo --input VIRCAM/raw/all,refcats,VIRCAM/calib --register-dataset-types -p './DRP.yaml#processCcd' --instrument lsst.obs.vista.VIRCAM  --output-run processCcdOutputs --do-raise -c isr:doBias=False -c isr:doBrighterFatter=False -c isr:doDark=False -c isr:doFlat=False -c isr:doDefect=False -c calibrate:doPhotoCal=True -c calibrate:doAstrometry=True 




#makeSkyMap.py 
#pipetask run
#butler make-discrete-skymap $repo VIRCAM --collections processCcdOutputs
butler register-skymap $repo -C makeSkyMap.py



pipetask run -b $repo --input processCcdOutputs --input skymaps --input  VIRCAM/raw/all,refcats,VIRCAM/calib  --register-dataset-types -p "./DRP.yaml#coaddition" --instrument lsst.obs.vista.VIRCAM --output-run coadd -c makeWarp:doApplySkyCorr=False -c makeWarp:doApplyExternalSkyWcs=False -c makeWarp:doApplyExternalPhotoCalib=False

pipetask run  -b $repo --input processCcdOutputs --input  VIRCAM/raw/all,refcats,VIRCAM/calib --input skymaps --input coadd --register-dataset-types --input  VIRCAM/raw/all,refcats,VIRCAM/calib  -p "./DRP.yaml#detection" --instrument lsst.obs.vista.VIRCAM --output-run coaddPhot_dec

pipetask run  -b $repo --input processCcdOutputs  --input  VIRCAM/raw/all,refcats,VIRCAM/calib --input skymaps --input coadd --input coaddPhot_dec  --register-dataset-types -p "./DRP.yaml#mergeDetections" --instrument lsst.obs.vista.VIRCAM --output-run coaddPhot_MD

# import HSC data 
# butler import $repo "${PWD}/../../dmu0/HSC 3,5.fits" --export-file "${PWD}/../../dmu0/dmu0_HSC/export.yaml" 

pipetask run  -b $repo --input processCcdOutputs --input skymaps --input  VIRCAM/raw/all,refcats,VIRCAM/calib --input coadd --input coaddPhot_dec --input coaddPhot_MD  --register-dataset-types -p  "./DRP.yaml#deblend" --instrument lsst.obs.vista.VIRCAM --output-run coaddPhot_DB



#multiBandDriver??
#pipetask run

