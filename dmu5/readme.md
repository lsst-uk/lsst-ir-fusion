# DMU5 Catalogue creation, comparisons, and diagnostics

In this folder we take the LSST stack outputs from DMU4 and stack the catalogues to make all field or even all sky catalogues. csv files for ingestion into the VISTA Scvience Archive are stored in 'dmu5/dmu5_$SURVEY/data/$band/$tract/$patch/'.

the large area catalogues are stacked using the patch lists in dmu4 for a given field and using isInner flags to remove overlap regions.


## Pipeline runs

We have been conducting pipeline runs in preparation for final runs with Rubin data. We are naming these prototype runs using P followed by the year and the run number for that year.


### P2021.1
This was the first complete run of overlapping HSC and VISTA data in the VHS, VIKING, and VIDEO surveys.

obs_vista git version:

https://github.com/lsst-uk/obs_vista/commit/aea4d1d68394366261bb441f342d0742c911e509

### P2020.1

This was the first large area run on VIDEO data in the SXDS field. 

obs_vista git version:

https://github.com/lsst-uk/obs_vista/commit/5e65367cd8f48c84b3a8d74f67b2a70bf95a5bf8

