#!/bin/bash
#Get latest weekly from https://github.com/lsst/lsst/tags
export weekly='w.2023.02'
unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH
mkdir -p source/$weekly
cd source/$weekly
curl -OL https://raw.githubusercontent.com/lsst/lsst/$weekly/scripts/newinstall.sh
bash newinstall.sh -ct
source loadLSST.bash
eups distrib install -t $weekly lsst_distrib
curl -sSL https://raw.githubusercontent.com/lsst/shebangtron/main/shebangtron | python


