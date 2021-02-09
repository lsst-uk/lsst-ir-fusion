# VISTA VIKING SURVEY

The images are stored on IRIS under '~/rds/rds-iris-ip005/data/private/VISTA/VIKING/' which may be linked to the './data' folder here to make relative links work. We also download the public catalogues to make the photometric reference catalogues from 

http://horus.roe.ac.uk:8080/vdfs/VSQL_form.jsp

We use the following queries to get around row limits:

```Shell
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
```


