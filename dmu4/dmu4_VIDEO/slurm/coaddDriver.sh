#!/bin/bash
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks

varArray="$(python jobDict.py $1 $2)"
varArray=($varArray)
tract=${varArray[0]}
patch=${varArray[1]}
numCPUs=10

echo "Job info:"
echo $tract
echo $patch
echo $numCPUs

for FILTER in Z Y J H Ks
do
    if [ -f ../data/rerun/coadd/deepCoadd-results/VISTA-$FILTER/$tract/$patch/calexp-VISTA-$FILTER-$tract-$patch.fits ]
    then
        echo "Already coadded VISTA-"$FILTER $tract $patch
    else
	echo "Running VISTA-"$FILTER $tract $patch
        VISITS=''
        for f in ../data/rerun/coadd/deepCoadd/VISTA-$FILTER/$tract/$patch/*; do export VISITS=$VISITS^${f:${#f}-23:6}; done
        VISITS=${VISITS//-}
	VISITS=${VISITS:1}
        #export VISITS=${VISITS//^/' --selectId filter=VISTA-$FILTER visit='}
        #assembleCoadd.py ../data --rerun coadd $Z_VISITS --id filter=VISTA-Z tract=$tract patch=$patch -j=$numCPUs
        #echo $VISITS
        coaddDriver.py ../data --rerun coadd --selectId filter=VISTA-$FILTER visit=$VISITS --id filter=VISTA-$FILTER tract=$tract patch=$patch --reuse-outputs-from all --no-versions --cores=$numCPUs
    fi
done


