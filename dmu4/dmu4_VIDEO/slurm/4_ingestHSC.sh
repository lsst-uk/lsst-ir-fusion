#!/bin/bash
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst-ir-fusion/setup.sh
repo=../../data
coaddRun=hscImports/pdr3_dud_full
#Register dataset types if not already done by earlier stages
# butler register-dataset-type $repo deepCoadd ExposureF band skymap tract patch
# butler register-dataset-type $repo deepCoadd_calexp ExposureF band skymap tract patch
# butler register-dataset-type $repo deepCoadd_det SourceCatalog band skymap tract patch
butler ingest-files --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter $repo deepCoadd $coaddRun ../../../dmu0/dmu0_HSC/data/calexp_1771.ecsv -t symlink
butler ingest-files --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter $repo deepCoadd_calexp $coaddRun ../../../dmu0/dmu0_HSC/data/calexp_1771.ecsv -t symlink
butler ingest-files --formatter=lsst.obs.base.formatters.fitsGeneric.FitsGenericFormatter $repo deepCoadd_det $coaddRun ../../../dmu0/dmu0_HSC/data/det_1771.ecsv -t symlink


