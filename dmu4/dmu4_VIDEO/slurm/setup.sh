#!/bin/bash

# Setup LSST Science pipeline environment.

# The weekly tag should be revised based on the installed stack
# version.
export weekly='w.2024.12'

# The address of install directory is:
# /home/ir-sare1/rds/rds-iris-ip005/Elham/lsst-ir-fusion/install, but
# to ensure it's independent of the user, I've opted for a relative
# address.
source ../../../install/source/${weekly}/loadLSST.bash
setup lsst_distrib
setup obs_vista
