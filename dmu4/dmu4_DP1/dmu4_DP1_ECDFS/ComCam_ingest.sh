#!/bin/bash

# Set location of Butler
export repo=data

# Ingest ComCam deepCoadd images and detection catalogs
butler ingest-files $repo deepCoadd ComCam/deepCoadd_results \
    ../../../dmu0/dmu0_ComCam/comcam_deepcoadd.ecsv \
    --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter

butler ingest-files $repo deepCoadd_calexp ComCam/deepCoadd_results \
    ../../../dmu0/dmu0_ComCam/comcam_deepcoadd.ecsv \
    --formatter=lsst.obs.base.formatters.fitsExposure.FitsExposureFormatter

butler ingest-files $repo deepCoadd_det ComCam/deepCoadd_results \
    ../../../dmu0/dmu0_ComCam/comcam_detection.ecsv \
    --formatter=lsst.obs.base.formatters.fitsGeneric.FitsGenericFormatter
