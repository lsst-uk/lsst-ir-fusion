# DMU0 External data

In this directory we describe all the external data that is used in this database. This is data that has not bee modified by code here. Eventually there will be a protocol for how this data may either be stored locally in this directory or referenced at some accessible location.

Any data folder must contain the mapper file to tell the LSST Butler that it is a data directory accessible to the mapper:

```Shell
echo "lsst.obs.hsc.HscMapper" > DATA/_mapper
```

## VISTA structure

Each survey is organised by night. For a given night there will be six stacks of 6(?) individual exposures. Each of the stacks is at a given pointing designed to fully cover a region. These six stacks are then also added into a 'tile'. We are aiming to work with the stacks which have already had instrument signature removal and flat fielding etc. We are therefore aiming at this stage to use the LSST stack to coadd these stacks including the necessary warping. We may later want to include the flexibility to ingest the tiles and simply use the stack to warp them to the required skymap.

## HSC structure

We are using the final HSC PDR2 calibrated exposure 'calexp' patches. This means we will not do any of the ccd processing of HSC images conducted by the stack. We simply want to conduct the detection and measurement stages on them in order to merge with VISTA.

## LSST structure

When LSST data becomes available we are expecting it to exactly mirror the HSC calexp structure.

## PanSTARRS

We need a reference catalogue for photometric and astrometric calibration. We will eventually do this with GAIA. We are currently aiming to do it with PanSTARRS as per the HSC example. As a first pass we have downloaded a public PanSTARRS catalogue. We need to understand how to ingest this into the Butler repository.


## Other data sets

Eventually we aim to also facilitate working with Euclid or other data sets.

# External data

This folder contains information regarding the location and structure of external data sets. The meta data yml files and csv files will give locations and summaries of image locations on the primary data centre. It wil be superseded by files with a matching structure in data_local in order to facilitate running small tests on a local machine.

## HSC data

The HSC data mirrors the folder structure of the PDR2 imaging. The data structure is described here:

In order to find the image for a given point on the sky...

## LSST data

Can we get the pixel base for LSST already? 


## VISTA data

The VISTA data is arranged first according to survey. They all appear to be organised according to date the images were taken.

### VIDEO

### VEILS



### VHS

