#!/bin/bash
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/stack23/loadLSST.bash
source /home/ir-shir1/rds/rds-iris-ip005/ras81/stack_2022_21/loadLSST.bash
setup lsst_distrib
setup obs_vista
#Turn off model measurements:
unsetup -j meas_modelfit
#gen3_workflow stuff:
#setup -r /home/ir-shir1/rds/rds-iris-ip005/ras81/stack23/stack/miniconda3-py38_4.9.2-1.0.0/Linux64/gen3_workflow/20220209_w50 -j 
setup -r /home/ir-shir1/rds/rds-iris-ip005/ras81/stack_2022_21/gen3_workflow -j 
export wq_env='/home/ir-shir1/rds/rds-iris-ip005/ras81/stack_2022_21/wq_env'
conda activate --stack ${wq_env}
export PYTHONPATH=${wq_env}/lib/python3.8/site-packages:${PYTHONPATH}
export PATH=${wq_env}/bin:${PATH}
export NUMEXPR_MAX_THREADS=1
export OMP_NUM_THREADS=1
export BPS_WMS_SERVICE_CLASS=desc.gen3_workflow.ParslService

