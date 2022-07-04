#!/bin/bash
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
