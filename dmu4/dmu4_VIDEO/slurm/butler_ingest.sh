#!/bin/bash

# Setup LSST Science pipeline environment; The weekly tag within the
# "setup.sh" file should be revised based on the installed stack
# version.
source setup.sh

# Set location of Butler
export repo=../data

# Delete old butler if already present
if [ -f $repo/butler.yaml ]; then
    rm -r $repo
fi

# Create the Butler
butler create $repo

# Register VIRCAM
butler register-instrument $repo lsstuk.obs.vista.VIRCAM

# Make and register the all sky skymap using local config file
butler register-skymap $repo -C "$OBS_VISTA_DIR/config/makeSkyMap.py"

# Import the reference catalogues to the butler
butler register-dataset-type $repo \
       ps1_pv3_3pi_20170110_vista SimpleCatalog htm7
cp -r ~/rds/rds-iris-ip005/ras81/lsst-ir-fusion/dmu2/data/video_gen3 $repo
cd $repo
cd ..
butler ingest-files -t copy data ps1_pv3_3pi_20170110_vista \
       refcats/video data/video_gen3/filename_to_htm.ecsv
rm -r data/video_gen3
cd slurm

# Import confidence maps and Ingest the raw exposures _st
butler register-dataset-type $repo confidence ExposureF instrument \
       band physical_filter exposure detector

for i in {0..5072}
do
  varArray="$(python jobDict.py $i sxds_images_job_dict_5073.json)"
  varArray=($varArray)
  dateObs=${varArray[0]}
  numObs=${varArray[1]}
  filter=${varArray[2]}
  filter=${filter/VISTA/VIRCAM}
  band=${filter:7:1}
  tracts=${varArray[3]}
  filename=${varArray[4]}
  visit=${varArray[5]}
  echo "Ingesting:"
  echo $i
  echo $dateObs
  echo $numObs
  echo $filter
  echo $tracts
  echo $filename
  rm ./tmp/tmp_stack.fit
  rm ./tmp/tmp_confidence.fit
  cp $filename ./tmp/tmp_stack.fit
  cp ${filename/st.fit/st_conf.fit} ./tmp/tmp_confidence.fit
  #visit="$(python fitToExpNum.py ./tmp/tmp_stack.fit)"
  echo $visit

  butler ingest-raws $repo $filename -t copy --output-run VIRCAM/raw/video
  butler ingest-files --formatter=lsstuk.obs.vista.VircamRawFormatter \
	 $repo confidence confidence/video ./tmp/confidence.ecsv \
	 --data-id exposure=$visit,band=$band,physical_filter=$filter -t copy
done

# Define the visits from the ingested exposures
butler define-visits $repo VIRCAM --collections VIRCAM/raw/video

# We don't have calibs but we need the collection for later processing
butler write-curated-calibrations $repo VIRCAM video
