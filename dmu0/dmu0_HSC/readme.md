# HSC data

The Hyper SuprimeCam (HSC) data is currently from PDR2. We aim to use both the detection catalogues to merge with VISTA detections produced by the LSST stack and also to use these detection catalogues on the public deep co-added HSC warps.

## Getting the data

The data is downloaded from the direct access filetree.

https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/

https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/

The file structure within those directories should mirror the policy file in the obs_subaru package at the time of creation. We are aiming to mirror this file structure policy with obs_vista data.



## Ingesting HSC data into the obs_vista Butler repository

We are currently experimenting with symlinks as the simplest way to 'ingest' these HSC images and detection catalogues into an obs_vista Butler repository.




ln -s $HSC_DATA/hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_dud/deepCoadd-results data/rerun/coadd/deepCoadd-results
