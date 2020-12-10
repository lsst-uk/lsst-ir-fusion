# VISTA - VIDEO

The [VIDEO](http://www-astro.physics.ox.ac.uk/~video/public/Home.html) (VISTA Deep Extragalactic Observations) are the deepest images we use.

## VISTA - VIDEO images

The images are stored in folders according to observation date. There are exposures, stacks, and reduced pawprints present.

## VISTA - VIDEO catalogues


These catalogues where downloaded from the VISTA Science Archive using the
[Freeform SQL Query](http://horus.roe.ac.uk:8080/vdfs/VSQL_form.jsp). The
VIDEODR5 (VIDEOv20150521) database was queried, and the table *videoSource* was
used as it's described in the schema as containing *merged sources from
detections in videoDetection*.

The description of the columns (from the DR4 version) is available
[there](http://horus.roe.ac.uk/vsa/www/VIDEODR4/VIDEODR4_TABLE_videoSourceSchema.html)

The SQL queries used are:

```sql
# For CDFS-SWIRE
SELECT * FROM videoSource WHERE ra BETWEEN 50.7 AND 55.5 AND dec BETWEEN -30.50 AND -25.92

# For ELAIS-S1
SELECT * FROM videoSource WHERE ra BETWEEN 6.3 AND 11.3 AND dec BETWEEN -45.60 AND -41.53

# For XMM-LSS
SELECT * FROM videoSource WHERE ra BETWEEN 32.1 AND 38.2 AND dec BETWEEN -7.53 AND -1.52
```

The video fields are fully included in LSST. Only XMM is covered by HSC.

In the catalogues, the position is given in radians (but strangely the queries
above succeed) so the columns were renamed to `RA_radians` and `DEC_radians` and
the columns `ra` and `dec` were added with the position in decimal degrees.
