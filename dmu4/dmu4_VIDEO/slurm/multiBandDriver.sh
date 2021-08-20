#!/bin/bash
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
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

if [ -f $repo/rerun/coadd/deepCoadd-results/VISTA-Y/$tract/$patch/forcedSrc-VISTA-Y-$tract-$patch.fits ]
then
    echo "Already run full photopipe on patch" $tract $patch
else
    mkdir -p $repo/rerun/coadd/deepCoadd-results/HSC-G/$tract/$patch
    mkdir -p $repo/rerun/coadd/deepCoadd-results/HSC-R/$tract/$patch
    mkdir -p $repo/rerun/coadd/deepCoadd-results/HSC-I/$tract/$patch
    mkdir -p $repo/rerun/coadd/deepCoadd-results/HSC-Z/$tract/$patch
    mkdir -p $repo/rerun/coadd/deepCoadd-results/HSC-Y/$tract/$patch

    cp -rn ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-G/$tract/$patch/{calexp*.fits,det*.fits} $repo/rerun/coadd/deepCoadd-results/HSC-G/$tract/$patch/
    cp -rn ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-R/$tract/$patch/{calexp*.fits,det*.fits} $repo/rerun/coadd/deepCoadd-results/HSC-R/$tract/$patch/
    cp -rn ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-I/$tract/$patch/{calexp*.fits,det*.fits} $repo/rerun/coadd/deepCoadd-results/HSC-I/$tract/$patch/
    cp -rn ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-Z/$tract/$patch/{calexp*.fits,det*.fits} $repo/rerun/coadd/deepCoadd-results/HSC-Z/$tract/$patch/
    cp -rn ../../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-Y/$tract/$patch/{calexp*.fits,det*.fits} $repo/rerun/coadd/deepCoadd-results/HSC-Y/$tract/$patch/
    multiBandDriver.py $repo --rerun coadd --id filter=VISTA-Z^VISTA-Y^VISTA-J^VISTA-H^VISTA-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y tract=$tract patch=$patch --reuse-outputs-from all --no-versions --cores=32
fi
