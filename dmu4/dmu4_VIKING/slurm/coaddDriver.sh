#!/bin/bash
##source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack_v21/loadLSST.bash
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks

varArray="$(python jobDict.py $1 $2)"
varArray=($varArray)
tract=${varArray[0]}
patch=${varArray[1]}
numCPUs=1

echo "Job info:"
echo $tract
echo $patch
echo $numCPUs

if [ -f ../data/rerun/coaddPhot/deepCoadd-results/VISTA-Z/$tract/$patch/calexp-VISTA-Z-$tract-$patch.fits ]
then
    echo "Already coadded VISTA-Z patch" $tract $patch
else
    Z_VISITS=''
    for f in ../data/rerun/coadd/deepCoadd/VISTA-Z/$tract/$patch/*; do export Z_VISITS=$Z_VISITS^${f:${#f}-23:6}; done
    export Z_VISITS=${Z_VISITS//-}
    export Z_VISITS=${Z_VISITS//^/' --selectId filter=VISTA-Z visit='}
    #assembleCoadd.py ../data --rerun coadd $Z_VISITS --id filter=VISTA-Z tract=$tract patch=$patch -j=$numCPUs
    coaddDriver.py ../data --rerun coadd:coaddPhot $Z_VISITS --id filter=VISTA-Z tract=$tract patch=$patch --reuse-outputs-from all --no-versions --cores=$numCPUs
fi

if [ -f ../data/rerun/coaddPhot/deepCoadd-results/VISTA-Y/$tract/$patch/calexp-VISTA-Y-$tract-$patch.fits ]
then
    echo "Already coadded VISTA-Y patch" $tract $patch
else
    Y_VISITS=''
    for f in ../data/rerun/coadd/deepCoadd/VISTA-Y/$tract/$patch/*; do export Y_VISITS=$Y_VISITS^${f:${#f}-23:6}; done
    export Y_VISITS=${Y_VISITS//-}
    export Y_VISITS=${Y_VISITS//^/' --selectId filter=VISTA-Y visit='}
    #assembleCoadd.py ../data --rerun coadd $Y_VISITS --id filter=VISTA-Y tract=$tract patch=$patch -j=$numCPUs
    coaddDriver.py ../data --rerun coadd:coaddPhot $Y_VISITS --id filter=VISTA-Y tract=$tract patch=$patch --reuse-outputs-from all --no-versions --cores=$numCPUs
fi

if [ -f ../data/rerun/coaddPhot/deepCoadd-results/VISTA-J/$tract/$patch/calexp-VISTA-J-$tract-$patch.fits ]
then
    echo "Already coadded VISTA-J patch" $tract $patch
else
    J_VISITS=''
    for f in ../data/rerun/coadd/deepCoadd/VISTA-J/$tract/$patch/*; do export J_VISITS=$J_VISITS^${f:${#f}-23:6}; done
    export J_VISITS=${J_VISITS//-}
    export J_VISITS=${J_VISITS//^/' --selectId filter=VISTA-J visit='}
    #assembleCoadd.py ../data --rerun coadd $J_VISITS --id filter=VISTA-J tract=$tract patch=$patch -j=$numCPUs
    coaddDriver.py ../data --rerun coadd:coaddPhot $J_VISITS --id filter=VISTA-J tract=$tract patch=$patch --reuse-outputs-from all --no-versions --cores=$numCPUs
fi

if [ -f ../data/rerun/coaddPhot/deepCoadd-results/VISTA-H/$tract/$patch/calexp-VISTA-H-$tract-$patch.fits ]
then 
    echo "Already coadded VISTA-H patch" $tract $patch
else
    H_VISITS=''
    for f in ../data/rerun/coadd/deepCoadd/VISTA-H/$tract/$patch/*; do export H_VISITS=$H_VISITS^${f:${#f}-23:6}; done
    export H_VISITS=${H_VISITS//-}
    export H_VISITS=${H_VISITS//^/' --selectId filter=VISTA-H visit='}
    #assembleCoadd.py ../data --rerun coadd $H_VISITS --id filter=VISTA-H tract=$tract patch=$patch -j=$numCPUs
    coaddDriver.py ../data --rerun coadd:coaddPhot $H_VISITS --id filter=VISTA-H tract=$tract patch=$patch --reuse-outputs-from all --no-versions --cores=$numCPUs
fi

if [ -f ../data/rerun/coaddPhot/deepCoadd-results/VISTA-Ks/$tract/$patch/calexp-VISTA-Ks-$tract-$patch.fits ]
then
    echo "Already coadded VISTA-Ks patch" $tract $patch
else    
    KS_VISITS=''
    for f in ../data/rerun/coadd/deepCoadd/VISTA-Ks/$tract/$patch/*; do export KS_VISITS=$KS_VISITS^${f:${#f}-23:6}; done
    export KS_VISITS=${KS_VISITS//-}
    export KS_VISITS=${KS_VISITS//^/' --selectId filter=VISTA-Ks visit='}
    #assembleCoadd.py ../data --rerun coadd $KS_VISITS --id filter=VISTA-Ks tract=$tract patch=$patch -j=$numCPUs
    coaddDriver.py ../data --rerun coadd:coaddPhot $KS_VISITS --id filter=VISTA-Ks tract=$tract patch=$patch --reuse-outputs-from all --no-versions --cores=$numCPUs
fi


