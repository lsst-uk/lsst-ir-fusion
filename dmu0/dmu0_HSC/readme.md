# HSC data

The Hyper SuprimeCam (HSC) data is currently from PDR2. We aim to use both the detection catalogues to merge with VISTA detections produced by the LSST stack and also to use these detection catalogues on the public deep co-added HSC warps.

## Getting the data

The data is downloaded from the direct access filetree.

https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/

https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/

The file structure within those directories should mirror the policy file in the obs_subaru package at the time of creation. We are aiming to mirror this file structure policy with obs_vista data.



## Ingesting HSC data into the obs_vista Butler repository

We are currently experimenting with symlinks as the simplest way to 'ingest' these HSC images and detection catalogues into an obs_vista Butler repository. Note however that by linking the directories the obs_vista package can then modify files in the original repo which is dangerous. It may therefore be better to fully copy these files.




ln -s $HSC_DATA/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-G data/rerun/coadd/deepCoadd-results/HSC-G
ln -s $HSC_DATA/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-R data/rerun/coadd/deepCoadd-results/HSC-R
ln -s $HSC_DATA/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-I data/rerun/coadd/deepCoadd-results/HSC-I
ln -s $HSC_DATA/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Z data/rerun/coadd/deepCoadd-results/HSC-Z
ln -s $HSC_DATA/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results/HSC-Y data/rerun/coadd/deepCoadd-results/HSC-Y


