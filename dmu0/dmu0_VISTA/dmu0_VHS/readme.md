# VISTA VHS

This folder stores images and catalogues from IRIS and some summary catalogues for the public data release. These are available from Edinburgh.


## Images

The images are stored accroding to observation date and contain exposures, reduced paw prints and the stacks that are ingested by the LSST science pipelines. We also have the tile coadds and the catalogues made from these which are used for comparison and tests.

## Catalogues

As our reference catalogue we use the VHS public catalogues on the VSA. These can be downloaded with the following SQL queries run seperately to keep under Vista Science Archive ([VSA](http://horus.roe.ac.uk:8080/vdfs/VSQL_form.jsp)) row limits.:

### PDR3

These generate the new PDR3 fields Spring and Autumn which cover the whole Wide overlap. The YJHK bandsare available.

```Shell
#Spring and Autumn
SELECT 
    SOURCEID,
    RA,
    DEC,
    PSTAR,
    YAPERMAG3,
    YAPERMAG3ERR,
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

These commands are for the original PDR2 fields W01-W06

```Shell
#W01
SELECT * from vhsSource WHERE ra > 14 AND ra < 24 AND dec > -3 AND dec < 3
#W02 XMM:
SELECT * from vhsSource WHERE ra > 28 AND ra < 41 AND dec > -8 AND dec < 3
#W03 GAMA09 - needs two queries to get round row limits
SELECT * from vhsSource WHERE ra > 125 AND ra < 140 AND dec > -3 AND dec < 3
SELECT * from vhsSource WHERE ra >= 140 AND ra < 156 AND dec > -3 AND dec < 3
#W04 GAMA12 and 15
SELECT * from vhsSource WHERE ra > 160 AND ra < 230 AND dec > -3 AND dec < 3
#W05 VVDS
SELECT * from vhsSource WHERE ra > 328 AND ra < 345 AND dec > -3 AND dec < 3
SELECT * from vhsSource WHERE ra >= 345 AND ra < 355 AND dec > -3 AND dec < 3
SELECT * from vhsSource WHERE ra >= 355 AND ra < 370 AND dec > -3 AND dec < 3
#W06 and W07 in northern hemisphere.
```
