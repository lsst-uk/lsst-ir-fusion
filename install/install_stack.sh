#!/bin/bash

# Get the latest weekly or official release tag from https://github.com/lsst/lsst/tags
#export weekly='w.2025.14'
export release='v29.2.1'

unset LSST_HOME EUPS_PATH LSST_DEVEL EUPS_PKGROOT REPOSITORY_PATH

#mkdir -p source/$weekly
#cd source/$weekly

mkdir -p source/$release
cd source/$release

# To install lsst pipleine with -X option for "exact" same environment with DP1.
# https://pipelines.lsst.io/install/lsstinstall.html#run-lsstinstall

curl -OL https://ls.st/lsstinstall
chmod u+x lsstinstall
./lsstinstall -X v29_2_1

source loadLSST.sh

eups distrib install -t v29_2_1 lsst_distrib
curl -sSL https://raw.githubusercontent.com/lsst/shebangtron/main/shebangtron | python
setup lsst_distrib


echo $EUPS_PATH
cd conda/envs/lsst-scipipe-10.1.0-exact/share/eups/Linux64

# Install "obs_vista" package
mkdir obs_vista
cd obs_vista
git clone https://github.com/lsst-uk/obs_vista.git
mv obs_vista 24.0.0.1
eups declare -t current obs_vista 24.0.0.1
setup obs_vista

# Get Python major.minor version from the loaded LSST environment
PYVER=$(python - <<'EOF'
import sys
print(f"{sys.version_info.major}.{sys.version_info.minor}")
EOF
)

echo "LSST Python version = $PYVER"

# Find install root from EUPS_PATH
INSTALL_DIR="$(cd "$EUPS_PATH/../../../../../" && pwd -P)"
wq_env="$INSTALL_DIR/conda/envs/wq_env"

echo "INSTALL_DIR = $INSTALL_DIR"
echo "wq_env      = $wq_env"

# Requirements for using ctrl_bps and the Parsl-based plug-in
conda create -y -p "$wq_env" -c conda-forge python="$PYVER" ndcctools

"$wq_env/bin/python" - <<'EOF'
import work_queue
print("work_queue OK")
EOF
