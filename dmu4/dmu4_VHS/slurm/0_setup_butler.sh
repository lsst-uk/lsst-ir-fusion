#!/bin/bash
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/stack23/loadLSST.bash
#source /Users/rs548/GitHub/lsst_stack/loadLSST.bash
#setup lsst_distrib
#setup obs_vista
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst-ir-fusion/setup.sh

export repo=/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data

#Do not rm database in script for safety

if [ ! -f $repo/butler.yaml ]; then
    #rm -r $repo
    butler create $repo
    #butler register-instrument $repo lsst.obs.subaru.HyperSuprimeCam
    butler register-instrument $repo lsst.obs.vista.VIRCAM
    #Make and register the all sky skymap using local config file
    butler register-skymap $repo -C "$OBS_VISTA_DIR/config/makeSkyMap.py"
    
    # Import the reference catalogues to the butler.
    butler register-dataset-type $repo ps1_pv3_3pi_20170110_vista SimpleCatalog htm7
    cp -r ../../../dmu2/data/vhs_gen3 $repo 
    cd $repo
    cd ..
    butler ingest-files -t direct data ps1_pv3_3pi_20170110_vista vhsRefCats data/vhs_gen3/filename_to_htm.ecsv 
    
    #Ingest the raw exposures _st for stacks [0-9] for exposures
    #butler ingest-raws $repo ../../dmu0/dmu0_VISTA/dmu0_VIDEO/data/*/*_st.fit 
    #Define the visits from the ingested exposures
    #butler define-visits $repo VIRCAM 
    #We don't have calibs but we need the collection for later processing
    #butler write-curated-calibrations $repo VIRCAM
fi 
