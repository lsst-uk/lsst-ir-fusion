#!/bin/bash

# Setup LSST Science pipeline environment; The weekly tag within the
# "setup.sh" file should be revised based on the installed stack
# version.
source setup.sh


# Set location of Butler
export repo=../data


# Set an environment variable to decide which config profile to use
export OBS_VISTA_PROFILE=ComCam


# Delete old butler if already present
if [ -f $repo/butler.yaml ]; then
    rm -r $repo
fi


# Create the Butler
butler create $repo


# Register VIRCAM
butler register-instrument $repo lsstuk.obs.vista.VIRCAM


# Make and register the all sky skymap using local config file
butler register-skymap $repo -C \
       "$OBS_VISTA_DIR/config/ComCam/makeSkyMap.py"


# Import the reference catalogues to the butler
butler register-dataset-type $repo \
       the_monster_20250219_vista SimpleCatalog htm7
cp -r ../../../dmu2/dmu2_DP1/data/video_cdfs $repo
cd $repo
cd ..
butler ingest-files -t copy data \
       the_monster_20250219_vista refcats/video \
       data/video_cdfs/filename_to_htm.ecsv
rm -r data/video_cdfs
cd dmu4_DP1_ECDFS


# Ingest the raw exposures *_st.fit
butler ingest-raws $repo \
       $(cat ../../../dmu0/dmu0_VISTA/dmu0_VIDEO_CDFS/cdfs_images.txt) \
       -t copy --output-run VIRCAM/raw/video_cdfs


# Define the visits from the ingested exposures
butler define-visits $repo VIRCAM --collections VIRCAM/raw/video_cdfs


# We don't have calibs but we need the collection for later processing
butler write-curated-calibrations $repo VIRCAM video


# Ingest confidence maps
butler register-dataset-type $repo confidence ExposureF instrument \
       band physical_filter exposure detector day_obs
butler ingest-files --formatter=lsstuk.obs.vista.VircamRawFormatter \
       $repo confidence confidence/video_cdfs \
       ../../../dmu0/dmu0_VISTA/dmu0_VIDEO_CDFS/cdfs_index_conf.ecsv -t copy
