#!/bin/bash
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
source /Users/raphaelshirley/Documents/github/lsst_stack/loadLSST.bash
#source /Users/raphaelshirley/Documents/github/stack22/loadLSST.bash
#setup obs_Vista first or else it will overide lsst_distrib with current
setup obs_vista 22.0.0-2 
setup lsst_distrib -t w_2021_33
#w_latest
#setup lsst_apps -t w_latest w_2021_33

export repo=data
#export TRACTS=8524 
#export PATCHES=3,5

# This should already be set, but doesn't harm to make sure:
export DYLD_LIBRARY_PATH=${LSST_LIBRARY_PATH}
export OBS_VISTA=/Users/raphaelshirley/Documents/github/stack22/stack/current/DarwinX86/obs_vista/22.0.0-2

if [ -f $repo/butler.yaml ]; then
    rm -rf $repo
fi

if [ ! -f $repo/butler.yaml ]; then
    #rm -r $repo
    butler create $repo
    butler register-instrument $repo lsst.obs.vista.VIRCAM
    #Make and register the all sky skymap using local config file
    butler register-skymap $repo -C makeSkyMap.py
    # Import the reference catalogues to the butler.
    #butler import $repo "${PWD}/../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat" --export-file "${PWD}/../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat/export.yaml" --skip-dimensions instrument,physical_filter,detector
    butler import $repo "${PWD}/../../dmu2/data/ref_cats_gen3_test" --export-file "${PWD}/../../dmu2/data/ref_cats_gen3_test/export.yaml" --skip-dimensions instrument,physical_filter,detector
    #Ingest the raw exposures _st for stacks [0-9] for exposures
    butler ingest-raws $repo ../../dmu0/dmu0_VISTA/dmu0_VIDEO/data/*/*_st.fit 
    #Define the visits from the ingested exposures
    butler define-visits $repo VIRCAM #--collections VIRCAM/raw/all
    #We don't have calibs but we need the collection for later processing
    butler write-curated-calibrations data VIRCAM
fi

#Run processCcd on some exposures singleFrame processCcd
#AND (exposure=658653 OR exposure=642039)
# AND exposure!=658681 AND exposure!=658723
pipetask run -d "(detector=10) AND physical_filter='VIRCAM-Ks' " -b $repo --input VIRCAM/raw/all,refcats,VIRCAM/calib --register-dataset-types -p './DRP.yaml#singleFrame' --instrument lsst.obs.vista.VIRCAM --output-run processCcdOutputs --debug #--extend-run --clobber-outputs --skip-existing

#butler register-skymap $repo -C makeSkyMap.py

#Coadd the exposures
pipetask run -b $repo --input processCcdOutputs --input skymaps --input  VIRCAM/raw/all,refcats,VIRCAM/calib  --register-dataset-types -p "./DRP.yaml#coaddition" --instrument lsst.obs.vista.VIRCAM --output-run coadd 
#Run photometry pipeline
pipetask run -b $repo --input processCcdOutputs --input  VIRCAM/raw/all,refcats,VIRCAM/calib --input skymaps --input coadd --register-dataset-types -p "./DRP.yaml#multiband" --instrument lsst.obs.vista.VIRCAM --output-run photo 




