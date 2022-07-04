#!/bin/bash
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst-ir-fusion/setup.sh
repo=../../data
coaddRun=u/ir-shir1/DRP/videoCoadd/20220608T123100Z
butler ingest-files --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter $repo deepCoadd $coaddRun ../../../dmu0/dmu0_HSC/data/calexp_1599.ecsv
butler ingest-files --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter $repo deepCoadd_calexp $coaddRun ../../../dmu0/dmu0_HSC/data/calexp_1599.ecsv
butler ingest-files --formatter=lsst.obs.base.formatters.fitsGeneric.FitsGenericFormatter $repo deepCoadd_det $coaddRun ../../../dmu0/dmu0_HSC/data/det_1599.ecsv


