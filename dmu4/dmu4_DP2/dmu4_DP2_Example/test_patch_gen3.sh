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
if [ -f $repo/butler.yaml ]; then
    rm -rf $repo
fi


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
