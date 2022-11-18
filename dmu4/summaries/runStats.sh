#!/bin/bash

export repo=/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data
for SURVEY in video
do
    for FILTER in Z Y J H Ks
    do
	for OUTTYPE in calexp
        do	
	    echo $SURVEY $FILTER $OUTTYPE
            ls $DMU/dmu4/data/${SURVEY}/data/rerun/coadd/deepCoadd-results/VISTA-$FILTER/*/*/$OUTTYPE*.fits | wc -l
        done
    done
done
