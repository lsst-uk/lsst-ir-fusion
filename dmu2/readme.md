# Reference catalogues

In this repository we make the astrometric and photometric reference catalogues. We are starting with the LSST/HSC PanSTARRS reference catalogues and adding in 2MASS. Colour correction is performed by the obs_vista package. A key part of using the reference catalogues is using appropriate colour terms. We investigate the relations between the catalogues including final catalogues as a further test in the notebook [./2_Colour_terms.ipynb](./2_Colour_terms.ipynb)

## PanSTARRS

We are using the HSC PanSTARRS/GAIA reference catalogue used for the public HSC releases. We also have a version limited to r<19 however the reduced depth affects astrometric calibration for VISTA.

## 2MASS

The 2MASS catalogues are described in the associated readme [../dmu0/dmu0_2MASS/readme.md](../dmu0/dmu0_2MASS/readme.md).

## LSST formatting

The catalogues must be provided in the LSST format. The format has changed. For instance it now requires degrees for right ascension and declination and magnitudes instead of fluxes. It must also be ingested into the repo with:


### Gen 3 format

The gen 3 ref cat ingester is described here:

https://pipelines.lsst.io/v/weekly/modules/lsst.meas.algorithms/creating-a-reference-catalog.html

The basic procedure is:

```Shell
setup meas_algorithms
mkdir data/video_gen3
convertReferenceCatalog data/video_gen3/ indexReferenceCatalogOverride.py "/Users/raphaelshirley/Documents/github/lsst-ir-fusion/dmu2/data/ref_cats_video/*" &> convert.log
```

These then need to be ingested into the Butler (as described in the convert.log file):

```Shell
butler register-dataset-type REPO cal_ref_cat SimpleCatalog htm7
butler ingest-files -t direct REPO ps1_pv3_3pi_20170110_vista refcats ../../dmu2/data/video_gen3/filename_to_htm.ecsv
```

### Gen 2 (deprecated)


```Shell
echo lsst.obs.test.TestMapper > data/_mapper
ingestReferenceCatalog.py data ./data/ref_cats_vhs/*.fits --output data/ref_cats_vhs_ingested/ --configfile indexReferenceCatalogOverride.py
```

This will put all the ref cats in this folder. These will then need to be linked in any repo which uses them or reingested. The basic process for creating a reference catalogue is described here:

https://pipelines.lsst.io/modules/lsst.meas.algorithms/creating-a-reference-catalog.html

## Notes

See useful discussion on reference catalogues here:

https://community.lsst.org/t/creating-and-using-new-style-reference-catalogs/1523/9

and here:

https://community.lsst.org/t/pan-starrs-reference-catalog-in-lsst-format/1572

Some code has been reused from here:

https://github.com/jrmullaney/filter_PanSTARRS