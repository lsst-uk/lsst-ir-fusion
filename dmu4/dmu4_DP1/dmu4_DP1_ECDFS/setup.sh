#!/bin/bash

unset PYTHONPATH PYTHONHOME
export PYTHONNOUSERSITE=1


# Setup LSST Science pipeline environment.

# The weekly tag should be revised based on the installed stack
# version.
#export weekly='w.2025.35'
export release='v29.2.1'

# Set an environment variable to decide which config profile to use
export OBS_VISTA_PROFILE=ComCam

BASE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"   # directory of setup.sh
TOP="$(cd "$BASE/../../.." && pwd -P)"                   # lsst-ir-fusion

# Load the LSST software environment into the shell
#source $TOP/install/source/${weekly}/loadLSST.bash
source "$TOP/install/source/${release}/loadLSST.sh"

# Setup Science Pipelines packages
setup lsst_distrib

# Setup "obs_vista" package
setup obs_vista

# Setup of wq_env for using ctrl_bps and the Parsl-based plug-in
#export wq_env="$TOP/install/source/${weekly}/stack/wq_env"
PYVER=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
export wq_env="$TOP/install/source/${release}/conda/envs/wq_env"
export PYTHONPATH="$wq_env/lib/python${PYVER}/site-packages:$PYTHONPATH"
export PATH="$PATH:$wq_env/bin"
export NUMEXPR_MAX_THREADS=1
export OMP_NUM_THREADS=1
