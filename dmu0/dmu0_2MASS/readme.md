# 2MASS photometric calibration catalogues

This product contains the 2MASS All-Sky Catalogue of Point Sources (Cutri et al., 2003). Its full documentation is available here: http://cdsarc.u-strasbg.fr/viz-bin/Cat?II/246

The all HSC coverage is downloaded from 

http://tapvizier.u-strasbg.fr/adql/?%20II/246/out

using the following query:

``` sql
 SELECT "II/246/out".RAJ2000,  "II/246/out".DEJ2000,  "II/246/out"."2MASS",  "II/246/out".Jmag,  "II/246/out".e_Jmag,  "II/246/out".Hmag,  "II/246/out".e_Hmag, 
 "II/246/out".Kmag,  "II/246/out".e_Kmag,  "II/246/out".Qflg,  "II/246/out".Rflg,  "II/246/out".Bflg,  "II/246/out".Cflg,  "II/246/out".Xflg,  "II/246/out".Aflg
 FROM "II/246/out"
WHERE ("II/246/out".DEJ2000 > -15 AND "II/246/out".DEJ2000 < 3)
```

The final all sky point source catalog was downloaded from:

https://irsa.ipac.caltech.edu/cgi-bin/Gator/nph-query

No restraints were put on the query.

[//]: # (We make 2MASS photometric reference catalogues as a test but they are superseeded by bootstrapped VISTA reference catalogeus which are themselves cal;ibrated against 2MASS. See [dmu2](../../dmu2/) for more information.)
