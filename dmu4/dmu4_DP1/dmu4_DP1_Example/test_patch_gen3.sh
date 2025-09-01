#!/bin/bash
# This script should conduct a full example run of a small subset of DP1

# Setup LSST science pipeline environment
export release='v29.1.1'
source ../../../install/source/${release}/loadLSST.bash

# Setup science pipelines packages
setup lsst_distrib

# Setup "obs_vista" package
setup obs_vista

# Set location of Butler
export repo=data

# Set an environment variable to decide which config profile to use
export OBS_VISTA_PROFILE=comCam


# Delete old butler if already present
if [ -f $repo/butler.yaml ]; then
    rm -rf $repo
fi


# Create the Butler
butler create $repo


# Register VIRCAM
butler register-instrument $repo lsstuk.obs.vista.VIRCAM


# Make and register the all sky skymap using local config file
butler register-skymap $repo -C "$OBS_VISTA_DIR/config/comCam/makeSkyMap.py"


# Import the reference catalogues to the butler.
butler register-dataset-type $repo the_monster_20250219_vista SimpleCatalog htm7
cp -r ../../../dmu2/dmu2_DP1/data/video_cdfs $repo
butler ingest-files -t copy $repo the_monster_20250219_vista refcats/video \
	data/video_cdfs/filename_to_htm.ecsv
rm -r $repo/video_cdfs


# Ingest the raw exposures _st for stacks [0-9] for exposures
butler ingest-raws $repo ../../../dmu0/dmu0_VISTA/dmu0_VIDEO_CSDF/data/*/*_st.fit \
	-t copy --output-run VIRCAM/raw/video


# Define the visits from the ingested exposures
butler define-visits $repo VIRCAM --collections VIRCAM/raw/video
# We don't have calibs but we need the collection for later processing
butler write-curated-calibrations $repo VIRCAM video


# Import confidence maps
butler register-dataset-type $repo \
    confidence ExposureF instrument band physical_filter exposure detector
butler ingest-files --formatter=lsstuk.obs.vista.VircamRawFormatter $repo \
    confidence confidence/video \
    ../../../dmu0/dmu0_VISTA/dmu0_VIDEO_CSDF/example_export_confidence.ecsv -t copy


# Run the singleFrame processing (detector 9 for example)
pipetask run -d "instrument='VIRCAM' AND detector IN (9)" \
    -b $repo \
    --input confidence/video,VIRCAM/raw/video,refcats/video,VIRCAM/calib/video,skymaps \
    --register-dataset-types \
    -p "$OBS_VISTA_DIR/pipelines/DRP-DP1.yaml#step1" \
    --output videoStep1


# Run the calibrate step
pipetask run -d "instrument='VIRCAM' AND skymap='lsst_cells_v1'" \
    -b $repo --input videoStep1 \
    --register-dataset-types \
    -p "$OBS_VISTA_DIR/pipelines/DRP-DP1.yaml#step2" \
    --output videoStep2


# Run the coadd step
pipetask run -d "tract=5063 AND patch IN (22) AND skymap='lsst_cells_v1'" \
    -b $repo \
    --input videoStep2 \
    --register-dataset-types \
    -p "$OBS_VISTA_DIR/pipelines/DRP-DP1.yaml#step3a" \
    --output videoStep3a
