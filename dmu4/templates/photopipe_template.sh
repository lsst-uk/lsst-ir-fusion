#!/bin/bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks


detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-Z tract={tract} patch={patch}
detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-Y tract={tract} patch={patch}
detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-J tract={tract} patch={patch}
detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-H tract={tract} patch={patch}
detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-Ks tract={tract} patch={patch}

#HSC files must be copied - Which bands to merge detections from?
#mergeCoaddDetections.py ../data --rerun coaddPhot --id filter=VISTA-Y^VISTA-J^VISTA-H^VISTA-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y tract={tract} patch={patch}
mergeCoaddDetections.py ../data --rerun coaddPhot --id filter=VISTA-Ks tract={tract} patch={patch}

deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Z tract={tract} patch={patch}
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Y tract={tract} patch={patch}
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-J tract={tract} patch={patch}
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-H tract={tract} patch={patch}
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Ks tract={tract} patch={patch}
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-G tract={tract} patch={patch}
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-R tract={tract} patch={patch}
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-I tract={tract} patch={patch}
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-Z tract={tract} patch={patch}
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-Y tract={tract} patch={patch}

measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Z tract={tract} patch={patch}
measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Y tract={tract} patch={patch}
measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-J tract={tract} patch={patch}
measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-H tract={tract} patch={patch}
measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Ks tract={tract} patch={patch}
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-G tract={tract} patch={patch}
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-R tract={tract} patch={patch}
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-I tract={tract} patch={patch}
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-Z tract={tract} patch={patch}
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-Y tract={tract} patch={patch}

mergeCoaddMeasurements.py ../data --rerun coaddPhot --id filter=VISTA-Y^VISTA-J^VISTA-H^VISTA-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y tract={tract} patch={patch}

forcedPhotCoadd.py ../data --rerun coaddPhot:coaddForcedPhot --id filter=VISTA-Z tract={tract} patch={patch}
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=VISTA-Y tract={tract} patch={patch}
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=VISTA-J tract={tract} patch={patch}
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=VISTA-H tract={tract} patch={patch}
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=VISTA-Ks tract={tract} patch={patch}
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-G tract={tract} patch={patch}
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-R tract={tract} patch={patch}
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-I tract={tract} patch={patch}
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-Z tract={tract} patch={patch}
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-Y tract={tract} patch={patch}
