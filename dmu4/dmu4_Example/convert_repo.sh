#!/bin/bash
source /Users/raphaelshirley/Documents/github/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista 21.0.0-1

butler convert --gen2root data_g2 data_g3_test

