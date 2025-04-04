#!/bin/bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks

for i in {0..47}
do 
  varArray="$(python jobDict.py $i processCcd_job_dict.json)"
  varArray=($varArray)
  dateObs=${varArray[0]}
  numObs=${varArray[1]}
  filter=${varArray[2]}
  tracts=${varArray[3]}
  filename=${varArray[4]}
  echo "Ingesting:"
  echo $dateObs
  echo $numObs
  echo $filter
  echo $tracts
  echo $filename
  ingestImages.py ../data $filename --ignore-ingested --clobber-config
done
#processCcd.py ../data --rerun processCcdOutputs --id dateObs=$dateObs numObs=$numObs --clobber-config
#makeCoaddTempExp.py ../data --rerun coadd --selectId dateObs=$dateObs numObs=$numObs filter=$filter --id filter=$filter tract=$tracts  --clobber-config
