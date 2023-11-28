
#source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst_stack/loadLSST.bash
source /Users/raphaelshirley/Documents/github/lsst_stack_2022_38/loadLSST.zsh
#source /Users/raphaelshirley/Documents/github/stack20220523/loadLSST.zsh

setup lsst_distrib 
setup obs_vista 
#setup meas_algorithms
#the following effectively switches off model measurements.
#unsetup -j meas_modelfit

export NUMEXPR_MAX_THREADS=4
export OMP_NUM_THREADS=4

export LEPHAREDIR=/Users/raphaelshirley/Documents/github/LEPHARE
export LEPHAREWORK=/Users/raphaelshirley/Documents/github/LEPHAREWORK



