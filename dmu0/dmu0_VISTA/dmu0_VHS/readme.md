# VISTA VHS

This folder stores images and catalogues from IRIS and some summary catalogues for the public data release. These are available from Edinburgh.


## Images

The images are stored accroding to observation date and contain exposures, reduced paw prints and the stacks that are ingested by the LSST science pipelines. We also have the tile coadds and the catalogues made from these which are used for comparison and tests.

## Catalogues

As our reference catalogue we use the VHS public catalogues on the VSA. These can be downloaded with the following SQL queries run seperately to keep under Vista Science Archive ([VSA](http://horus.roe.ac.uk:8080/vdfs/VSQL_form.jsp))row limits.:

```Shell
#W01
SELECT * from vhsSource WHERE ra > 14 AND ra < 24 AND dec > -3 AND dec < 3
#W02 XMM:
SELECT * from vhsSource WHERE ra > 28 AND ra < 41 AND dec > -8 AND dec < 3
#W03 GAMA09
SELECT * from vhsSource WHERE ra > 125 AND ra < 156 AND dec > -3 AND dec < 3
#W03 GAMA09
SELECT * from vhsSource WHERE ra > 125 AND ra < 156 AND dec > -3 AND dec < 3
#W04 GAMA12 and 15
SELECT * from vhsSource WHERE ra > 160 AND ra < 230 AND dec > -3 AND dec < 3
#W05 VVDS
SELECT * from vhsSource WHERE ra > 125 AND ra < 156 AND dec > -3 AND dec < 3
#W06 and W07 in northern hemisphere.
```