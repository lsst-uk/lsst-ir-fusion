# VISTA VIKING SURVEY

The images are stored on IRIS under '~/rds/rds-iris-ip005/data/private/VISTA/VIKING/' which may be linked to the './data' folder here to make relative links work. We also download the public catalogues to make the photometric reference catalogues from 

http://horus.roe.ac.uk:8080/vdfs/VSQL_form.jsp

We use the following queries to get around row limits:

```Shell
SELECT * from vikingSource WHERE ra > 180 AND dec > -30
SELECT * from vikingSource WHERE ra <= 180 AND dec > -30
```


