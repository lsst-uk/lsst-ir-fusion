#!/bin/bash
# This script should conduct a full example run of a small subset of DP2

# Setup LSST science pipeline environment
export release='v30_0_10'
source ../../../install/source/${release}/loadLSST.bash

# Setup science pipelines packages
setup lsst_distrib

# Setup "obs_vista" package
setup obs_vista

# Set location of Butler
export repo=data

# Set an environment variable to decide which config profile to use
export OBS_VISTA_PROFILE=LSSTCam


# Delete old butler if already present
#if [ -f $repo/butler.yaml ]; then
#    rm -rf $repo
#fi


# Create the Butler
butler create $repo


# Register VIRCAM
butler register-instrument $repo lsstuk.obs.vista.VIRCAM


# Make and register the all sky skymap using local config file
butler register-skymap $repo -C "$OBS_VISTA_DIR/config/LSSTCam/makeSkyMap.py"


# Import the reference catalogues to the butler.
butler register-dataset-type $repo the_monster_20250219_vista SimpleCatalog htm7


# ------------------------------------------------------------
# Approach 1
# Monster astrometry + direct VIDEO Z,Y,J,H,Ks photometry
# ------------------------------------------------------------
cp -r ../../../dmu2/dmu2_DP2/data/video_elais_ap1 $repo
butler ingest-files -t copy $repo \
    the_monster_20250219_vista \
    refcats/video_elais_ap1 \
    data/video_elais_ap1/filename_to_htm.ecsv
rm -r $repo/video_elais_ap1


# ------------------------------------------------------------
# Approach 2
# Monster astrometry + transformed Z/Y + VIDEO J,H,Ks
# ------------------------------------------------------------
cp -r ../../../dmu2/dmu2_DP2/data/video_elais_ap2 $repo
butler ingest-files -t copy $repo \
    the_monster_20250219_vista \
    refcats/video_elais_ap2 \
    data/video_elais_ap2/filename_to_htm.ecsv
rm -r $repo/video_elais_ap2


# Ingest the raw exposures _st for stacks [0-9] for exposures
# Instead of "-t copy" we can use "-t hardlink"
butler ingest-raws $repo ../../../dmu0/dmu0_VISTA/dmu0_VIDEO_ELAIS/data/*_st.fit \
	-t copy --output-run VIRCAM/raw/video_elais


# Define the visits from the ingested exposures
butler define-visits $repo VIRCAM --collections VIRCAM/raw/video_elais
# We don't have calibs but we need the collection for later processing
butler write-curated-calibrations $repo VIRCAM video_elais


# Import confidence maps
butler register-dataset-type $repo \
    confidence ExposureF instrument band physical_filter exposure detector
butler ingest-files --formatter=lsstuk.obs.vista.VircamRawFormatter $repo \
    confidence confidence/video_elais \
    ../../../dmu0/dmu0_VISTA/dmu0_VIDEO_ELAIS/example_export_confidence.ecsv -t copy


# Run the singleFrame processing (detectors 10 and 11 for example)
pipetask run -b $repo  --register-dataset-types \
    -d "instrument='VIRCAM' AND detector IN (10, 11)" \
    -i confidence/video_elais,VIRCAM/raw/video_elais,refcats/video_elais_ap2,VIRCAM/calib/video_elais,skymaps \
    -p "$OBS_VISTA_DIR/pipelines/DRP-DP2.yaml#step1" \
    -o videoStep1 -j10


# Run the calibrate step
pipetask run -b $repo --register-dataset-types \
    -d "instrument='VIRCAM' AND skymap='lsst_cells_v2'" \
    -i videoStep1 \
    -p "$OBS_VISTA_DIR/pipelines/DRP-DP2.yaml#step2" \
    -o videoStep2


# Run the Warp step
pipetask run -b $repo --register-dataset-types \
    -d "tract=2877 AND patch IN (77) AND skymap='lsst_cells_v2'" \
    -i videoStep2 \
    -p "$OBS_VISTA_DIR/pipelines/DRP-DP2.yaml#step3a" \
    -o videoStep3a -j10


# Run the Coadd step
pipetask run -b $repo --register-dataset-types \
    -d "tract=2877 AND patch IN (77) AND skymap='lsst_cells_v2'" \
    -i videoStep2,videoStep3a \
    -p "$OBS_VISTA_DIR/pipelines/DRP-DP2.yaml#step3b" \
    -o videoStep3b -j10


# Ingest Optical data
python ingest_dp2_optical_predetection.py \
  --repo "$repo" \
  --input-dir ../../../dmu0/dmu0_LSSTCam/data/dp2_elais/predetection \
  --run LSSTCam/elais/optical_predetections \
  --skymap lsst_cells_v2 \
  --tract 2877 --patch 77 \
  --bands u g r i z y


# Creating optical detections in butler
pipetask run -b $repo --register-dataset-types \
  -d "instrument='LSSTCam' AND skymap='lsst_cells_v2' AND tract=2877 AND patch=77" \
  -i "LSSTCam/elais/optical_predetections" \
  -p "$OBS_VISTA_DIR/pipelines/DP2-optical-detection.yaml" \
  -o "LSSTCam/elais/optical_detections" -j 6


# Run the Coadd step
pipetask run -b $repo --register-dataset-types \
  -d "instrument='VIRCAM' AND skymap='lsst_cells_v2' AND tract=2877 AND patch=77" \
  -i "videoStep3b,LSSTCam/elais/optical_detections" \
  -p "$OBS_VISTA_DIR/pipelines/DRP-DP2.yaml#step3c" \
  -o videoStep3c -j 11
