#!/bin/bash

# Setup LSST Science pipeline environment; The weekly tag within the
# "setup.sh" file should be revised based on the installed stack
# version.
source ./setup.sh

# Set location of Butler
export repo=../data

coaddRun=hscImports/pdr3_dud_full
#Register dataset types if not already done by earlier stages
# butler register-dataset-type $repo deepCoadd ExposureF band skymap tract patch
# butler register-dataset-type $repo deepCoadd_calexp ExposureF band skymap tract patch
# butler register-dataset-type $repo deepCoadd_det SourceCatalog band skymap tract patch
butler ingest-files --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter \
       $repo deepCoadd $coaddRun \
       ~/rds/rds-iris-ip005/ras81/lsst-ir-fusion/dmu0/dmu0_HSC/export/calexp_1771.ecsv -t symlink
butler ingest-files --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter \
       $repo deepCoadd_calexp $coaddRun \
       ~/rds/rds-iris-ip005/ras81/lsst-ir-fusion/dmu0/dmu0_HSC/export/calexp_1771.ecsv -t symlink
butler ingest-files --formatter=lsst.obs.base.formatters.fitsGeneric.FitsGenericFormatter \
       $repo deepCoadd_det $coaddRun \
       ~/rds/rds-iris-ip005/ras81/lsst-ir-fusion/dmu0/dmu0_HSC/export/det_1771.ecsv -t symlink

