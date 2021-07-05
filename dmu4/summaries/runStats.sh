#!/bin/bash
for SURVEY in VIDEO VHS VIKING
do
    for FILTER in Z Y J H Ks
    do
	for OUTTYPE in det meas forc
        do	
	    echo $SURVEY $FILTER $OUTTYPE
            ls $DMU/dmu4/dmu4_$SURVEY/data/rerun/coadd/deepCoadd-results/VISTA-$FILTER/*/*/$OUTTYPE*.fits | wc -l
        done
    done
done
