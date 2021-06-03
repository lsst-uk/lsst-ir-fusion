#!/bin/bash
source /Users/raphaelshirley/Documents/github/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista 21.0.0-1
export tract=8524 
export patch=3,5
export repo=data

rm -r $repo
mkdir $repo

echo "lsst.obs.vista.VistaMapper" > ./data/_mapper 

mkdir -p data/ref_cats/ps1_pv3_3pi_20170110_vista

cp -n ../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat/* data/ref_cats/ps1_pv3_3pi_20170110_vista

while read p; do
  ingestImages.py data "$p" --ignore-ingested 
done <minimal_stacks.lis

processCcd.py $repo --rerun test --id 

makeSkyMap.py $repo  --rerun test 
coaddDriver.py $repo --selectId filter=VISTA-Z --id filter=VISTA-Z tract=$tract patch=$patch --no-versions --cores=1
coaddDriver.py $repo --selectId filter=VISTA-Y --id filter=VISTA-Y tract=$tract patch=$patch --no-versions --cores=1
coaddDriver.py $repo --selectId filter=VISTA-J --id filter=VISTA-J tract=$tract patch=$patch --no-versions --cores=1
coaddDriver.py $repo --selectId filter=VISTA-H --id filter=VISTA-H tract=$tract patch=$patch --no-versions --cores=1
coaddDriver.py $repo --selectId filter=VISTA-Ks --id filter=VISTA-Ks tract=$tract patch=$patch --no-versions --cores=1

mkdir -p $repo/deepCoadd-results/HSC-G/$tract/$patch
mkdir -p $repo/deepCoadd-results/HSC-R/$tract/$patch
mkdir -p $repo/deepCoadd-results/HSC-I/$tract/$patch
mkdir -p $repo/deepCoadd-results/HSC-Z/$tract/$patch
mkdir -p $repo/deepCoadd-results/HSC-Y/$tract/$patch
cp -r ../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/$tract/$patch/{calexp*.fits,det*.fits} $repo/deepCoadd-results/HSC-G/$tract/$patch/
cp -r ../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/$tract/$patch/{calexp*.fits,det*.fits} $repo/deepCoadd-results/HSC-R/$tract/$patch/
cp -r ../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/$tract/$patch/{calexp*.fits,det*.fits} $repo/deepCoadd-results/HSC-I/$tract/$patch/
cp -r ../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/$tract/$patch/{calexp*.fits,det*.fits} $repo/deepCoadd-results/HSC-Z/$tract/$patch/
cp -r ../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/$tract/$patch/{calexp*.fits,det*.fits} $repo/deepCoadd-results/HSC-Y/$tract/$patch/

multiBandDriver.py $repo  --rerun test --id filter=VISTA-Z^VISTA-Y^VISTA-J^VISTA-H^VISTA-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y tract=$tract patch=$patch --no-versions --cores=1

