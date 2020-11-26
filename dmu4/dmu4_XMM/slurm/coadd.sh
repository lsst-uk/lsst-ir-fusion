#!/bin/bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks

varArray="$(python jobDict.py $1 processCcd_job_dict.json)"
varArray=($varArray)
tract=${varArray[0]}
patch=${varArray[1]}
numCPUs=10

echo "Job info:"
echo $tract
echo $patch
echo $numCPUs


for f in ../data/rerun/coadd/deepCoadd/VISTA-J/$tract/$patch/*; do export J_VISITS=$J_VISITS^${{f:${{#f}}-23:6}}; done
export J_VISITS=${{J_VISITS//-}}
export J_VISITS=${{J_VISITS//^/' --selectId filter=VISTA-J visit='}}
assembleCoadd.py ../data --rerun coadd $J_VISITS --id filter=VISTA-J tract=$tract patch=$patch -j=$numCPUs

for f in ../data/rerun/coadd/deepCoadd/VISTA-H/$tract/$patch/*; do export H_VISITS=$H_VISITS^${{f:${{#f}}-23:6}}; done
export H_VISITS=${{H_VISITS//-}}
export H_VISITS=${{H_VISITS//^/' --selectId filter=VISTA-H visit='}}
assembleCoadd.py ../data --rerun coadd $H_VISITS --id filter=VISTA-H tract=$tract patch=$patch -j=$numCPUs

for f in ../data/rerun/coadd/deepCoadd/VISTA-Ks/$tract/$patch/*; do export KS_VISITS=$KS_VISITS^${{f:${{#f}}-23:6}}; done
export KS_VISITS=${{KS_VISITS//-}}
export KS_VISITS=${{KS_VISITS//^/' --selectId filter=VISTA-Ks visit='}}
assembleCoadd.py ../data --rerun coadd $KS_VISITS --id filter=VISTA-Ks tract=$tract patch=$patch -j=$numCPUs