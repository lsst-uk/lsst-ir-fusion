#!/bin/bash
#Get latest weekly from https://github.com/lsst/lsst/tags
export weekly='w.2023.25'
unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH

mkdir -p source/$weekly
cd source/$weekly
curl -OL https://raw.githubusercontent.com/lsst/lsst/$weekly/scripts/newinstall.sh
bash newinstall.sh -ctb
source loadLSST.bash
eups distrib install -t w_latest lsst_distrib
curl -sSL https://raw.githubusercontent.com/lsst/shebangtron/main/shebangtron | python

# obs_vista installation
#cd stack/current/Linux64/
cd stack/current/Darwin64/
mkdir obs_vista
cd obs_vista
git clone https://github.com/lsst-uk/obs_vista.git
mv obs_vista 24.0.0.1
eups declare -t current obs_vista 24.0.0.1 

