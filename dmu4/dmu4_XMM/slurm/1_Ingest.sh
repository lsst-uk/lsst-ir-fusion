#!/bin/bash
# source /home/ir-shir1/lsst_stack/loadLSST.bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
for d in {2009,2010,2011,2012,2013,2014,2015,2016,2017,2018,2019}; do ingestImages.py ../data /home/ir-shir1/rds/rds-iris-ip005/data/private/VISTA/VHS/$d*/*_st.fit; done

