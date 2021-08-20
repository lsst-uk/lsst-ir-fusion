#!/bin/bash
#source /Users/raphaelshirley/Documents/github/lsst_stack/loadLSST.bash
#setup lsst_distrib
#setup obs_vista 21.0.0-2
source /Users/raphaelshirley/Documents/github/stack22/loadLSST.bash
setup lsst_distrib
setup obs_vista 22.0.0-2
export TRACT=8524 
export PATCH=3,5
export REPO=dataGen2N
export RERUN=test
export HSC=../../dmu0/dmu0_HSC/data/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud

rm -r $REPO
mkdir $REPO

echo "lsst.obs.vista.VircamMapper" > $REPO/_mapper 

mkdir -p $REPO/ref_cats/ps1_pv3_3pi_20170110_vista

cp -n ../../dmu2/data/ref_cats_video_ingested/ref_cats/cal_ref_cat/* \
$REPO/ref_cats/ps1_pv3_3pi_20170110_vista

#while read p; do
#  ingestImages.py $REPO "$p" --ignore-ingested 
#done <minimal_stacks.lis
ingestDriver.py $REPO ../../dmu0/dmu0_VISTA/dmu0_VIDEO/data/20121122/*st.fit --cores=1

#patch 8524 3,5 only involves ccds 9 and 10
processCcd.py $REPO --rerun $RERUN --id ccdnum=9^10
#singleFrameDriver.py --cores=1

makeSkyMap.py $REPO  --rerun $RERUN
for FILTER in Ks
do
   coaddDriver.py $REPO --rerun $RERUN --selectId filter=VIRCAM-$FILTER --id \
   filter=VIRCAM-$FILTER tract=$TRACT patch=$PATCH --cores=1
done

for FILTER in I
do
   mkdir -p $REPO/rerun/$RERUN/deepCoadd-results/HSC-$FILTER/$TRACT/$PATCH
   cp -n $HSC/deepCoadd-results/HSC-$FILTER/$TRACT/$PATCH/{calexp*.fits,det*.fits} \
   $REPO/rerun/$RERUN/deepCoadd-results/HSC-$FILTER/$TRACT/$PATCH/
done

multiBandDriver.py $REPO  --rerun $RERUN --id \
filter=VIRCAM-Z^VIRCAM-Y^VIRCAM-J^VIRCAM-H^VIRCAM-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y \
tract=$TRACT patch=$PATCH --cores=1 --clobber-config

#writeObjectTable.py dataGen2N --rerun test --id \
#filter=VIRCAM-Z^VIRCAM-Y^VIRCAM-J^VIRCAM-H^VIRCAM-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y \
#tract=$TRACT patch=$PATCH --configfile writeConfig.py
