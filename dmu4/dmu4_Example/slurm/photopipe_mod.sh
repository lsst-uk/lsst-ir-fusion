#!/bin/bash
source /rfs/project/rfs-L33A9wsNuJk/shared/lsst_stack/loadLSST.bash
setup lsst_distrib
setup obs_vista
eups admin clearLocks

varArray="$(python jobDict.py $1 patch_job_dict.json)"
varArray=($varArray)
tract=${varArray[0]}
patch=${varArray[1]}


echo "Photopipe job info:"
echo $tract
echo $patch

credArray="$(python credentials.py)"
credArray=($credArray)
user=${credArray[0]}
password=${credArray[1]}


detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-Z tract=$tract patch=$patch
detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-Y tract=$tract patch=$patch
detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-J tract=$tract patch=$patch
detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-H tract=$tract patch=$patch
detectCoaddSources.py ../data --rerun coadd:coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch

#HSC files must be copied - Which bands to merge detections from?
#wget --user $user --password $password -r -l2 --no-parent -nc -nd \
#--directory-prefix=../data/rerun/coaddPhot/deepCoadd-results/HSC-G/$tract/$patch \
#https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-G/$tract/$patch/calexp-HSC-G-$tract-$patch.fits

#wget --user $user --password $password -r -l2 --no-parent -nc -nd \
#--directory-prefix=../data/rerun/coaddPhot/deepCoadd-results/HSC-R/$tract/$patch \
#https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-R/$tract/$patch/calexp-HSC-R-$tract-$patch.fits

#wget --user $user --password $password -r -l2 --no-parent -nc -nd \
#--directory-prefix=../data/rerun/coaddPhot/deepCoadd-results/HSC-I/$tract/$patch \
#https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-I/$tract/$patch/calexp-HSC-I-$tract-$patch.fits

#wget --user $user --password $password -r -l2 --no-parent -nc -nd \
#--directory-prefix=../data/rerun/coaddPhot/deepCoadd-results/HSC-Z/$tract/$patch \
#https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-Z/$tract/$patch/calexp-HSC-Z-$tract-$patch.fits

#wget --user $user --password $password -r -l2 --no-parent -nc -nd \
#--directory-prefix=../data/rerun/coaddPhot/deepCoadd-results/HSC-Y/$tract/$patch \
#https://hsc-release.mtk.nao.ac.jp/archive/filetree/pdr2_wide/deepCoadd-results/HSC-Y/$tract/$patch/calexp-HSC-Y-$tract-$patch.fits




mergeCoaddDetections.py ../data --rerun coaddPhot --id filter=VISTA-Y^VISTA-J^VISTA-H^VISTA-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y tract=$tract patch=$patch
#mergeCoaddDetections.py ../data --rerun coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch

deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Z tract=$tract patch=$patch
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Y tract=$tract patch=$patch
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-J tract=$tract patch=$patch
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-H tract=$tract patch=$patch
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-G tract=$tract patch=$patch
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-R tract=$tract patch=$patch
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-I tract=$tract patch=$patch
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-Z tract=$tract patch=$patch
deblendCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-Y tract=$tract patch=$patch

measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Z tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py
measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Y tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py
measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-J tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py
measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-H tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py
measureCoaddSources.py ../data --rerun coaddPhot --id filter=VISTA-Ks tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-G tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-R tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-I tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-Z tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py
measureCoaddSources.py ../data --rerun coaddPhot --id filter=HSC-Y tract=$tract patch=$patch --clobber-config --configfile ../config/measureCoaddSources.py

mergeCoaddMeasurements.py ../data --rerun coaddPhot --id filter=VISTA-Y^VISTA-J^VISTA-H^VISTA-Ks^HSC-G^HSC-R^HSC-I^HSC-Z^HSC-Y tract=$tract patch=$patch

forcedPhotCoadd.py ../data --rerun coaddPhot:coaddForcedPhot --id filter=VISTA-Z tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=VISTA-Y tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=VISTA-J tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=VISTA-H tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=VISTA-Ks tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-G tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-R tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-I tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-Z tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
forcedPhotCoadd.py ../data --rerun coaddForcedPhot --id filter=HSC-Y tract=$tract patch=$patch --clobber-config --configfile ../config/forcedPhotCoadd.py
