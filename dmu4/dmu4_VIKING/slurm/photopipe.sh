#!/bin/bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack_v21/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks

varArray="$(python jobDict.py $1 $2)"
varArray=($varArray)
tract=${varArray[0]}
patch=${varArray[1]}
repo=../data

echo "Photopipe job info:"
echo $tract
echo $patch


detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-Z tract=$tract patch=$patch
detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-Y tract=$tract patch=$patch
detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-J tract=$tract patch=$patch
detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-H tract=$tract patch=$patch
detectCoaddSources.py $repo --rerun coadd:coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch

mkdir -p $repo/rerun/coaddPhot/deepCoadd-results/HSC-G/$tract
mkdir -p $repo/rerun/coaddPhot/deepCoadd-results/HSC-R/$tract
mkdir -p $repo/rerun/coaddPhot/deepCoadd-results/HSC-I/$tract
mkdir -p $repo/rerun/coaddPhot/deepCoadd-results/HSC-Z/$tract
mkdir -p $repo/rerun/coaddPhot/deepCoadd-results/HSC-Y/$tract

cp -r ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-G/$tract/$patch $repo/rerun/coaddPhot/deepCoadd-results/HSC-G/$tract/
cp -r ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-R/$tract/$patch $repo/rerun/coaddPhot/deepCoadd-results/HSC-R/$tract/
cp -r ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-I/$tract/$patch $repo/rerun/coaddPhot/deepCoadd-results/HSC-I/$tract/
cp -r ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-Z/$tract/$patch $repo/rerun/coaddPhot/deepCoadd-results/HSC-Z/$tract/
cp -r ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-Y/$tract/$patch $repo/rerun/coaddPhot/deepCoadd-results/HSC-Y/$tract/

mergeCoaddDetections.py $repo --rerun coaddPhot --id filter=VISTA-Z^VISTA-Y^VISTA-J^VISTA-H^VISTA-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y tract=$tract patch=$patch



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

forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=VISTA-Z tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=VISTA-Y tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=VISTA-J tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=VISTA-H tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=HSC-G tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=HSC-R tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=HSC-I tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=HSC-Z tract=$tract patch=$patch
forcedPhotCoadd.py $repo --rerun coaddPhot --id filter=HSC-Y tract=$tract patch=$patch
