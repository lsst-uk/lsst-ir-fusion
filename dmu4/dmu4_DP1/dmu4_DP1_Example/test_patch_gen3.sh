#!/bin/bash
# This script should conduct a full example run of a small subset of DP1

# Setup LSST Science pipeline environment
export release='v29.1.1'
source ../../../install/source/${release}/loadLSST.bash

# Setup Science Pipelines packages
setup lsst_distrib

# Setup "obs_vista" package
setup obs_vista

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
butler register-skymap $repo -C "$OBS_VISTA_DIR/config/comCam/makeSkyMap.py"

# Import the reference catalogues to the butler.
butler register-dataset-type $repo the_monster_20250219_vista SimpleCatalog htm7
cp -r ../../../dmu2/dmu2_DP1/data/video_cdfs $repo
butler ingest-files -t copy $repo the_monster_20250219_vista refcats/video \
	data/video_cdfs/filename_to_htm.ecsv
rm -r $repo/video_cdfs 
