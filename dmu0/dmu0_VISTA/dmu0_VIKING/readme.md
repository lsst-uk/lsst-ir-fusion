# VISTA VIKING SURVEY

The images are stored on IRIS under '~/rds/rds-iris-ip005/data/private/VISTA/VIKING/' which may be linked to the './data' folder here to make relative links work. We also download the public catalogues to make the photometric reference catalogues from 

http://horus.roe.ac.uk:8080/vdfs/VSQL_form.jsp

### PDR3

These generate the new PDR3 fields Spring and Autumn which cover the whole Wide overlap.

```Shell
#Spring and Autumn - very simply defined in terms of two rectangles
SELECT 
    SOURCEID,
    RA,
    DEC,
    PSTAR,
    JAPERMAG3,
    JAPERMAG3ERR,
    HAPERMAG3,
    HAPERMAG3ERR,
    KSAPERMAG3,
    KSAPERMAG3ERR 
FROM vhsSource WHERE 
((ra < 45 OR ra > 325) AND dec > -3 AND dec < 3)
OR ((ra < 45 AND ra > 25) AND dec > -10 AND dec <= -3)
OR (ra > 120 AND ra < 235 AND dec > -3 AND dec < 3)
```

### PDR2

We use the following queries to get around row limits:

```Shell
#W03 and W04 GAMA fields
SELECT * from vikingSource WHERE ra > 120 AND ra < 130 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 130 AND ra < 140 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 140 AND ra < 150 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 150 AND ra < 160 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 160 AND ra < 170 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 170 AND ra < 180 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 180 AND ra < 190 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 190 AND ra < 200 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 200 AND ra < 210 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 210 AND ra < 220 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 220 AND ra < 230 AND dec > -30 AND pStar >= 0.9
SELECT * from vikingSource WHERE ra >= 230 AND ra < 240 AND dec > -30 AND pStar >= 0.9
#W02 SXDS/XMM region
SELECT * from vikingSource WHERE ra > 32 AND ra < 38 AND dec > -8 AND pStar >= 0.9
```


