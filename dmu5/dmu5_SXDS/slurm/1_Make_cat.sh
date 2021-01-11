#!/bin/bash
# source /home/ir-shir1/lsst_stack/loadLSST.bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks

/usr/bin/time -o trace -a -f '%C %M kb %e s' jupyter nbconvert --to notebook --execute --ExecutePreprocessor.timeout=-1 ../1_Make_cat.ipynb --ExecutePreprocessor.kernel_name=lsst
