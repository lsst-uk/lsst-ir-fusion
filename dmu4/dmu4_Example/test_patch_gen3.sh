#!/bin/bash
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
source /Users/raphaelshirley/Documents/github/lsst_stack/loadLSST.bash
setup obs_vista 23.0.0-1
setup lsst_distrib -t w_latest

export repo=data

if [ -f $repo/butler.yaml ]; then
    rm -rf $repo
fi

if [ ! -f $repo/butler.yaml ]; then
    #rm -r $repo
    butler create $repo
    #butler register-instrument $repo lsst.obs.subaru.HyperSuprimeCam
    butler register-instrument $repo lsst.obs.vista.VIRCAM
    #Make and register the all sky skymap using local config file
    #butler register-skymap $repo -C makeSkyMap.py
    
    # Import the reference catalogues to the butler.
    butler register-dataset-type $repo ps1_pv3_3pi_20170110_vista SimpleCatalog htm7
    cp -r ../../dmu2/data/video_gen3 $repo 
    butler ingest-files -t direct $repo ps1_pv3_3pi_20170110_vista refcats data/video_gen3/filename_to_htm.ecsv 
    
    #Ingest the raw exposures _st for stacks [0-9] for exposures
    #butler ingest-raws $repo ../../dmu0/dmu0_VISTA/dmu0_VIDEO/data/*/*_st.fit -t copy
    butler ingest-raws $repo ../../dmu0/dmu0_VISTA/dmu0_VIDEO/data/20121122/v20121122_00088_st.fit -t copy
    #Define the visits from the ingested exposures
    butler define-visits $repo VIRCAM 
    #We don't have calibs but we need the collection for later processing
    butler write-curated-calibrations $repo VIRCAM
fi

#Import confidence maps
#butler import $repo "../../dmu0/dmu0_VISTA/dmu0_VIDEO" --export-file "../../dmu0/dmu0_VISTA/dmu0_VIDEO/export_test.yaml" 
butler register-dataset-type $repo confidence ExposureF instrument band physical_filter exposure detector
butler ingest-files --formatter=lsst.obs.vista.VircamRawFormatter $repo confidence videoTest ../../dmu0/dmu0_VISTA/dmu0_VIDEO/test_export_confidence_658653.ecsv

#Run processCcd on some exposures singleFrame processCcd
pipetask run -d "detector IN (9,10) AND band IN ('K') " -b $repo --input videoTest,VIRCAM/raw/all,refcats,VIRCAM/calib --register-dataset-types -p './DRP.yaml#singleFrame' --instrument lsst.obs.vista.VIRCAM --output-run videoTest  --extend-run #--clobber-outputs --skip-existing

#Coadd the exposures
pipetask run -d "tract=8524 AND patch IN (39,48) AND skymap='hscPdr2' " -b $repo --input videoTest,skymaps,VIRCAM/raw/all,refcats,VIRCAM/calib  --register-dataset-types -p "./DRP.yaml#coaddition" --instrument lsst.obs.vista.VIRCAM --output-run videoTest --extend-run 

#Import HSC images
butler import $repo "../../dmu0/dmu0_HSC" --export-file "../../dmu0/dmu0_HSC/export.yaml" 

#Run photometry pipeline
pipetask run -d "tract=8524 AND patch IN (39,48) AND skymap='hscPdr2' " -b $repo --input videoTest,VIRCAM/raw/all,refcats,VIRCAM/calib,skymaps --register-dataset-types -p "./DRP.yaml#multiVisitLater" --instrument lsst.obs.vista.VIRCAM --output-run videoTest --extend-run

