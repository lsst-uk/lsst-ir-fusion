#!/bin/bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks

varArray="$(python jobDict.py $1 patch_job_dict.json)"
varArray=($varArray)
tract=${varArray[0]}
patch=${varArray[1]}
repo=../data

echo "Photopipe job info:"
echo $tract
echo $patch

credArray="$(python credentials.py)"
credArray=($credArray)
user=${credArray[0]}
password=${credArray[1]}


detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-Z tract=$tract patch=$patch
detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-Y tract=$tract patch=$patch
detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-J tract=$tract patch=$patch
detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-H tract=$tract patch=$patch
detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch


mergeCoaddDetections.py $repo --rerun coaddPhot --id filter=VISTA-Z^VISTA-Y^VISTA-J^VISTA-H^VISTA-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y tract=$tract patch=$patch
#mergeCoaddDetections.py $repo --rerun coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch

deblendCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-Z tract=$tract patch=$patch
deblendCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-Y tract=$tract patch=$patch
deblendCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-J tract=$tract patch=$patch
deblendCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-H tract=$tract patch=$patch
deblendCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch
deblendCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-G tract=$tract patch=$patch
deblendCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-R tract=$tract patch=$patch
deblendCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-I tract=$tract patch=$patch
deblendCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-Z tract=$tract patch=$patch
deblendCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-Y tract=$tract patch=$patch

measureCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-Z tract=$tract patch=$patch
measureCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-Y tract=$tract patch=$patch
measureCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-J tract=$tract patch=$patch
measureCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-H tract=$tract patch=$patch
measureCoaddSources.py $repo --rerun coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch
measureCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-G tract=$tract patch=$patch
measureCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-R tract=$tract patch=$patch
measureCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-I tract=$tract patch=$patch
measureCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-Z tract=$tract patch=$patch
measureCoaddSources.py $repo --rerun coaddPhot --id filter=HSC-Y tract=$tract patch=$patch

mergeCoaddMeasurements.py $repo --rerun coaddPhot --id filter=VISTA-Z^VISTA-Y^VISTA-J^VISTA-H^VISTA-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y tract=$tract patch=$patch

forcedPhotCoadd.py $repo --rerun coaddPhot:coaddForcedPhot --id filter=VISTA-Z tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddForcedPhot --id filter=VISTA-Y tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddForcedPhot --id filter=VISTA-J tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddForcedPhot --id filter=VISTA-H tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddForcedPhot --id filter=VISTA-Ks tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddForcedPhot --id filter=HSC-G tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddForcedPhot --id filter=HSC-R tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddForcedPhot --id filter=HSC-I tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddForcedPhot --id filter=HSC-Z tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddForcedPhot --id filter=HSC-Y tract=$tract patch=$patch
