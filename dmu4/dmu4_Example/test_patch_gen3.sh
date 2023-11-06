#!/bin/bash
#This script should conduct a full example run of a small subset of VIDEO

#Setup LSST Science pipeline environment
source ../../setup_mac.sh

#Set location of Butler
export repo=data

#Delete old butler if already present
if [ -f $repo/butler.yaml ]; then
    rm -rf $repo
fi


#Create the Butler
butler create $repo
#Register VIRCAM
butler register-instrument $repo lsstuk.obs.vista.VIRCAM
#Make and register the all sky skymap using local config file
butler register-skymap $repo -C "$OBS_VISTA_DIR/config/makeSkyMap.py"

# Import the reference catalogues to the butler.
butler register-dataset-type $repo ps1_pv3_3pi_20170110_vista SimpleCatalog htm7
cp -r ../../dmu2/data/video_gen3 $repo  # VIDEO ref
butler ingest-files -t copy $repo ps1_pv3_3pi_20170110_vista refcats/video \
	data/video_gen3/filename_to_htm.ecsv 
rm -r $repo/video_gen3

#Ingest the raw exposures _st for stacks [0-9] for exposures
butler ingest-raws $repo ../../dmu0/dmu0_VISTA/dmu0_VIDEO/data/*/*_st.fit \
	-t copy --output-run VIRCAM/raw/video

#Define the visits from the ingested exposures
butler define-visits $repo VIRCAM --collections VIRCAM/raw/video
#We don't have calibs but we need the collection for later processing
butler write-curated-calibrations $repo VIRCAM


#Import confidence maps
butler register-dataset-type $repo \
    confidence ExposureF instrument band physical_filter exposure detector
butler ingest-files --formatter=lsstuk.obs.vista.VircamRawFormatter $repo \
    confidence confidence/video \
    ../../dmu0/dmu0_VISTA/dmu0_VIDEO/test_export_confidence.ecsv -t copy 

#Run the singleFrame processing
pipetask run -d "detector IN (9,10) AND band IN ('J','K')" \
    -b $repo --input confidence/video,VIRCAM/raw/video,refcats/video,VIRCAM/calib \
    --register-dataset-types -p "$OBS_VISTA_DIR/pipelines/DRP_full.yaml#singleFrame" \
    --output videoSingleFrame  

#Coadd the exposures
pipetask run -d "tract=8524 AND patch IN (39,48) AND skymap='hscPdr2' " \
    -b $repo \
    --input videoSingleFrame \
    --register-dataset-types -p "$OBS_VISTA_DIR/pipelines/DRP_full.yaml#coaddDetect" \
    --output videoCoaddDetect

#Import HSC deepCoadd images and detections
export coaddRun=hsc/pdr3_dud
butler ingest-files \
    --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter $repo \
    deepCoadd $coaddRun ../../dmu0/dmu0_HSC/data/calexp_2.ecsv
butler ingest-files \
    --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter $repo \
    deepCoadd_calexp $coaddRun ../../dmu0/dmu0_HSC/data/calexp_2.ecsv
butler ingest-files \
    --formatter=lsst.obs.base.formatters.fitsGeneric.FitsGenericFormatter $repo \
    deepCoadd_det $coaddRun ../../dmu0/dmu0_HSC/data/det_2.ecsv

#Run photometry pipeline
pipetask run -d "tract=8524 AND patch IN (39,48) AND skymap='hscPdr2' " -b $repo \
    --input videoCoaddDetect,$coaddRun \
    --register-dataset-types \
    -p "$OBS_VISTA_DIR/pipelines/DRP_full.yaml#multiVisitLater" \
    --output videoMultiVisitLater

