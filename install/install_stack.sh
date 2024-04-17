#!/bin/bash

# Get latest weekly from https://github.com/lsst/lsst/tags
export weekly='w.2024.15'
unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH

mkdir -p source/$weekly
cd source/$weekly

# Download and run of "newinstall.sh"
curl -OL https://raw.githubusercontent.com/lsst/lsst/$weekly/scripts/newinstall.sh
bash newinstall.sh -ctb

# Load the LSST software environment into the shell
source loadLSST.bash

# Install Science Pipelines packages
eups distrib install -t w_latest lsst_distrib
curl -sSL https://raw.githubusercontent.com/lsst/shebangtron/main/shebangtron | python

# Install "obs_vista" package
cd stack/current/
# try Linux
cd Linux64
# try Mac
cd DarwinX86
mkdir obs_vista
cd obs_vista
git clone https://github.com/lsst-uk/obs_vista.git
mv obs_vista 24.0.0.1
eups declare -t current obs_vista 24.0.0.1

# Requirements for using ctrl_bps and the Parsl-based plug-in
cd ../../../
wq_env=`pwd -P`/wq_env
conda create --prefix ${wq_env}
conda activate --stack ${wq_env}
conda install -c conda-forge ndcctools --no-deps
