#!/bin/bash
# source /home/ir-shir1/lsst_stack/loadLSST.bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
ingestImages.py data /home/ir-shir1/rds/rds-iris-ip005/data/private/VISTA/VIDEO/**/*_st.fit 
