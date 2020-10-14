#!/bin/bash
#Prepare Butler repo for processCcd and runPhotopipe slurm runs
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks
ingestImages.py data /home/ir-shir1/rds/rds-iris-ip005/data/private/VISTA/VIDEO/**/*_st.fit
mkdir -p data/rerun/coaddPhot/deepCoadd-results/HSC-G
mkdir -p data/rerun/coaddPhot/deepCoadd-results/HSC-R
mkdir -p data/rerun/coaddPhot/deepCoadd-results/HSC-I
mkdir -p data/rerun/coaddPhot/deepCoadd-results/HSC-Z
mkdir -p data/rerun/coaddPhot/deepCoadd-results/HSC-Y
mkdir -p data/rerun/processCcdOutputs/coadd
makeSkyMap.py data --rerun processCcdOutputs:coadd --clobber-config
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/8282 data/rerun/coaddPhot/deepCoadd-results/HSC-G 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/8283 data/rerun/coaddPhot/deepCoadd-results/HSC-G 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/8284 data/rerun/coaddPhot/deepCoadd-results/HSC-G 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/8523 data/rerun/coaddPhot/deepCoadd-results/HSC-G 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/8524 data/rerun/coaddPhot/deepCoadd-results/HSC-G 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/8525 data/rerun/coaddPhot/deepCoadd-results/HSC-G 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/8765 data/rerun/coaddPhot/deepCoadd-results/HSC-G 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/8766 data/rerun/coaddPhot/deepCoadd-results/HSC-G 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G/8767 data/rerun/coaddPhot/deepCoadd-results/HSC-G 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/8282 data/rerun/coaddPhot/deepCoadd-results/HSC-R 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/8283 data/rerun/coaddPhot/deepCoadd-results/HSC-R 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/8284 data/rerun/coaddPhot/deepCoadd-results/HSC-R 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/8523 data/rerun/coaddPhot/deepCoadd-results/HSC-R 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/8524 data/rerun/coaddPhot/deepCoadd-results/HSC-R 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/8525 data/rerun/coaddPhot/deepCoadd-results/HSC-R 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/8765 data/rerun/coaddPhot/deepCoadd-results/HSC-R 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/8766 data/rerun/coaddPhot/deepCoadd-results/HSC-R 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R/8767 data/rerun/coaddPhot/deepCoadd-results/HSC-R 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/8282 data/rerun/coaddPhot/deepCoadd-results/HSC-I 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/8283 data/rerun/coaddPhot/deepCoadd-results/HSC-I 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/8284 data/rerun/coaddPhot/deepCoadd-results/HSC-I 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/8523 data/rerun/coaddPhot/deepCoadd-results/HSC-I 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/8524 data/rerun/coaddPhot/deepCoadd-results/HSC-I 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/8525 data/rerun/coaddPhot/deepCoadd-results/HSC-I 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/8765 data/rerun/coaddPhot/deepCoadd-results/HSC-I 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/8766 data/rerun/coaddPhot/deepCoadd-results/HSC-I 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I/8767 data/rerun/coaddPhot/deepCoadd-results/HSC-I 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/8282 data/rerun/coaddPhot/deepCoadd-results/HSC-Z 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/8283 data/rerun/coaddPhot/deepCoadd-results/HSC-Z 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/8284 data/rerun/coaddPhot/deepCoadd-results/HSC-Z 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/8523 data/rerun/coaddPhot/deepCoadd-results/HSC-Z 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/8524 data/rerun/coaddPhot/deepCoadd-results/HSC-Z 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/8525 data/rerun/coaddPhot/deepCoadd-results/HSC-Z 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/8765 data/rerun/coaddPhot/deepCoadd-results/HSC-Z 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/8766 data/rerun/coaddPhot/deepCoadd-results/HSC-Z 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z/8767 data/rerun/coaddPhot/deepCoadd-results/HSC-Z 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/8282 data/rerun/coaddPhot/deepCoadd-results/HSC-Y 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/8283 data/rerun/coaddPhot/deepCoadd-results/HSC-Y 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/8284 data/rerun/coaddPhot/deepCoadd-results/HSC-Y 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/8523 data/rerun/coaddPhot/deepCoadd-results/HSC-Y 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/8524 data/rerun/coaddPhot/deepCoadd-results/HSC-Y 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/8525 data/rerun/coaddPhot/deepCoadd-results/HSC-Y 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/8765 data/rerun/coaddPhot/deepCoadd-results/HSC-Y 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/8766 data/rerun/coaddPhot/deepCoadd-results/HSC-Y 
cp -r /home/ir-shir1/rds/rds-iris-ip005/data/public/HSC/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y/8767 data/rerun/coaddPhot/deepCoadd-results/HSC-Y 
