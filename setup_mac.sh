#!/bin/zsh
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
#source /Users/raphaelshirley/Documents/github/lsst_stack/loadLSST.bash
source /Users/raphaelshirley/Documents/github/stack20220523/loadLSST.zsh
setup obs_vista 23.0.0-1
setup lsst_distrib -t w_2022_21
setup meas_algorithms
#the following effectively switches off model measurements.
unsetup meas_modelfit

export NUMEXPR_MAX_THREADS=4
export OMP_NUM_THREADS=4

export LEPHAREDIR=/Users/raphaelshirley/Documents/github/LEPHARE
export LEPHAREWORK=/Users/raphaelshirley/Documents/github/LEPHAREWORK



