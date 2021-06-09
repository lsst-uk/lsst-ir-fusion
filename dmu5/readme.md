# DMU5 Catalogue creation, comparisons, and diagnostics

In this folder we take the LSST Science Pipeline outputs from the Butler repositories in dmu4 and combine the catalogues to make all field or even all sky catalogues. CSV files for ingestion into the VISTA Science Archive (VSA) are stored in 'dmu5/dmu5_$SURVEY/data/$band/$tract/$patch/'.

The large area reduced column catalogues are stacked using the patch lists in dmu4 for a given field and using isInner flags to remove overlap regions.

## Data access

The raw files are currently private. The first prototype run is being served on the VSA:

http://horus.roe.ac.uk:8080/vdfs/WP35_form.jsp

Example query:

"""
SELECT TOP 10 * FROM 
    HSCG, 
    HSCR, 
    HSCI, 
    HSCZ, 
    HSCY, 
    VISTAZ,
    VISTAY,
    VISTAJ,
    VISTAH, 
    VISTAKs  
WHERE HSCG.id=HSCR.id 
AND HSCG.id=HSCI.id 
AND HSCG.id=HSCZ.id 
AND HSCG.id=HSCY.id 
AND HSCG.id=VISTAZ.id 
AND HSCG.id=VISTAY.id 
AND HSCG.id=VISTAJ.id 
AND HSCG.id=VISTAH.id 
AND HSCG.id=VISTAKs.id 

AND VISTAKs.tract=8524
AND VISTAKs.patchx=3
AND VISTAKs.patchy=5
"""


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

