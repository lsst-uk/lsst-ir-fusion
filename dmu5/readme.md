# DMU5 Catalogue creation, comparisons, and diagnostics

In this folder we take the LSST Science Pipeline outputs from the Butler repositories in dmu4 and combine the catalogues to make all field or even all sky catalogues. CSV files for ingestion into the VISTA Science Archive (VSA) are stored in 'dmu5/dmu5_$SURVEY/data/$band/$tract/$patch/'.

The large area reduced column catalogues are stacked using the patch lists in dmu4 for a given field and using isInner flags to remove overlap regions.

## Data access

The raw files are currently private. The first prototype run is being served on the VSA:

http://horus.roe.ac.uk:8080/vdfs/WP35_form.jsp

Example query:

``` sql
SELECT TOP 10 * FROM
   VIKING_HSC_G_Meas as HSCG,
   VIKING_HSC_R_Meas as HSCR,
   VIKING_HSC_I_Meas as HSCI,
   VIKING_HSC_Z_Meas as HSCZ,
   VIKING_HSC_Y_Meas as HSCY,
   VIKING_VISTA_Z_Meas as VISTAZ,
   VIKING_VISTA_Y_Meas as VISTAY,
   VIKING_VISTA_J_Meas as VISTAJ,
   VIKING_VISTA_H_Meas as VISTAH,
   VIKING_VISTA_Ks_Meas as VISTAKs
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
```

The full list of tables is:

``` sql
VHS_HSC_G_Meas
VHS_HSC_I_Meas
VHS_HSC_R_Meas
VHS_HSC_Y_Meas
VHS_HSC_Z_Meas
VHS_VISTA_H_Meas
VHS_VISTA_J_Meas
VHS_VISTA_Ks_Meas
VIDEO_HSC_G_Meas
VIDEO_HSC_I_Meas
VIDEO_HSC_R_Meas
VIDEO_HSC_Y_Meas
VIDEO_HSC_Z_Meas
VIDEO_VISTA_H_Meas
VIDEO_VISTA_J_Meas
VIDEO_VISTA_Ks_Meas
VIDEO_VISTA_Y_Meas
VIDEO_VISTA_Z_Meas
VIKING_HSC_G_Meas
VIKING_HSC_I_Meas
VIKING_HSC_R_Meas
VIKING_HSC_Y_Meas
VIKING_HSC_Z_Meas
VIKING_VISTA_H_Meas
VIKING_VISTA_J_Meas
VIKING_VISTA_Ks_Meas
VIKING_VISTA_Y_Meas
VIKING_VISTA_Z_Meas
```

There are thousands of columns in each table. We advise getting a small test table first and selecting only the columns you need for a larger query.
## Pipeline runs

We have been conducting pipeline runs in preparation for final runs with Rubin data. We are naming these prototype runs using P followed by the year and the run number for that year.

### P2021.2
This run is upcoming. Changes to be made for upcoming run:

1) Use the generation 3 Butler.
2) Read number of dithers from stack header to set gain.
3) Apply confidence maps to variance plane.
4) Scale variance plane using autocorrelation to account for correlated noise.
5) Investigate using exposures instead of stacks.
6) Put all surveys in a single butler.

### P2021.1
This was the first complete run of overlapping HSC and VISTA data in the VHS, VIKING, and VIDEO surveys.

obs_vista git version:

https://github.com/lsst-uk/obs_vista/commit/aea4d1d68394366261bb441f342d0742c911e509

### P2020.1

This was the first large area run on VIDEO data in the SXDS field. 

obs_vista git version:

https://github.com/lsst-uk/obs_vista/commit/5e65367cd8f48c84b3a8d74f67b2a70bf95a5bf8

