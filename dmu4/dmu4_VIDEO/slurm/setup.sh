#!/bin/bash

# Setup LSST Science pipeline environment.

# The weekly tag should be revised based on the installed stack
# version.
#export weekly='w.2025.14'
export release='v29.0.1'

# Load the LSST software environment into the shell
# source ../../../install/source/${weekly}/loadLSST.bash
source ../../../install/source/${release}/loadLSST.bash

# Setup Science Pipelines packages
setup lsst_distrib

# Setup "obs_vista" package
setup obs_vista

# Setup of wq_env for using ctrl_bps and the Parsl-based plug-in
export wq_env=../../../install/source/${release}/stack/wq_env
conda activate --stack ${wq_env}
export PYTHONPATH=${wq_env}/lib/python3.13/site-packages:${PYTHONPATH}
export PATH=${wq_env}/bin:${PATH}
export NUMEXPR_MAX_THREADS=1
export OMP_NUM_THREADS=1
