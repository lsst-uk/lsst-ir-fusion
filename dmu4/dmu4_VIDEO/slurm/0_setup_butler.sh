#!/bin/bash

# Setup LSST Science pipeline environment; The weekly tag within the
# "setup.sh" file should be revised based on the installed stack
# version.
source ./setup.sh

# Set location of Butler
export repo=../data

# Delete old butler if already present
if [ -f $repo/butler.yaml ]; then
    rm -r $repo
fi

# Create the Butler
butler create $repo

# Register VIRCAM
butler register-instrument $repo lsst.obs.vista.VIRCAM

# Make and register the all sky skymap using local config file
butler register-skymap $repo -C "$OBS_VISTA_DIR/config/makeSkyMap.py"

# Import the reference catalogues to the butler
butler register-dataset-type $repo ps1_pv3_3pi_20170110_vista SimpleCatalog htm7
cp -r ~/rds/rds-iris-ip005/ras81/lsst-ir-fusion/dmu2/data/video_gen3 $repo
cd $repo
cd ..
butler ingest-files -t copy data ps1_pv3_3pi_20170110_vista \
       refcats/video data/video_gen3/filename_to_htm.ecsv
rm -r data/video_gen3
