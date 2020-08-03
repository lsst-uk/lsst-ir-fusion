#!/bin/bash
# source /home/ir-shir1/lsst_stack/loadLSST.bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
/usr/bin/time -o trace -a -f '%C %M kb %e s' jupyter nbconvert --to notebook --execute --ExecutePreprocessor.timeout=-1 1_Data_overview.ipynb --output 1_Data_overview-out.ipynb --ExecutePreprocessor.kernel_name=lsst
