#!/bin/bash

# Setup LSST Science pipeline environment
source ./setup.sh

# Set location of Butler
export repo=../data

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
butler write-curated-calibrations $repo VIRCAM
