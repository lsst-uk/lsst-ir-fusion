#!/bin/bash
#source /rfs/project/rfs-L33A9wsNuJk/shared/stack23/loadLSST.bash
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/stack23/loadLSST.bash
#setup lsst_distrib
#setup obs_vista
#eups admin clearLocks
#export NUMEXPR_MAX_THREADS=32
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst-ir-fusion/setup.sh

#butler ingest-raws ../../data /home/ir-shir1/rds/rds-iris-ip005/data/private/VISTA/VIDEO/*/*st.fit -t copy -j 32
export repo=/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/data
#butler register-dataset-type $repo confidence ExposureF instrument band physical_filter exposure detector

#for i in {17868..18489}
#do 
#  varArray="$(python jobDict.py $i full_images_job_dict_18490.json)"
#  varArray=($varArray)
#  dateObs=${varArray[0]}
#  numObs=${varArray[1]}
#  filter=${varArray[2]}
#  filter=${filter/VISTA/VIRCAM}
#  band=${filter:7:1}
#  tracts=${varArray[3]}
#  filename=${varArray[4]}
#  visit=${varArray[5]}
#  echo "Ingesting:"
#  echo $i
#  echo $dateObs
#  echo $numObs
#  echo $filter
#  echo $tracts
#  echo $filename
#  rm ./tmp/tmp_stack.fit
#  rm ./tmp/tmp_confidence.fit
#  filename=${filename/"/home/ir-shir1/rds/rds-iris-ip005/data/private/VISTA/VIKING"/"/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/vista/viking"}
#  cp $filename ./tmp/tmp_stack.fit
#  cp ${filename/st.fit/st_conf.fit} ./tmp/tmp_confidence.fit
#  #visit="$(python fitToExpNum.py ./tmp/tmp_stack.fit)"
#  echo $visit
#  
#  butler ingest-raws $repo $filename -t copy --output-run VIRCAM/raw/viking
#  butler ingest-files --formatter=lsst.obs.vista.VircamRawFormatter $repo confidence confidence/viking ./tmp/confidence.ecsv --data-id exposure=$visit,band=$band,physical_filter=$filter -t copy
#done

#Define the visits from the ingested exposures
butler define-visits $repo VIRCAM --collections VIRCAM/raw/viking
#We don't have calibs but we need the collection for later processing
#butler write-curated-calibrations $repo VIRCAM

