# DMU0 External data

In this directory we describe all the external data that is used in this database. This is data that has not been modified by code here but is used as an input. Eventually there will be a protocol for how this data may either be stored locally in this directory or referenced at some accessible location.

The data was originally stored on CSD3 under:

```shell
~/rds/rds-iris-ip005/private/VISTA
```

It is in the process of being moved to S3 storage which requires the MC code to use on Linux.


### MC usage

By default mc loads midnight commander so you need to give the full path to mc

```shell
wget https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
./mc config host add iris http://128.232.222.169:9000 rshirley vista12345
./mc ls iris/vista
```


## VISTA structure

Each survey is organised by night. For a given night there will be six stacks of 6(?) individual exposures. Each of the stacks is at a given pointing designed to fully cover a region. These six stacks are then also added into a 'tile'. We are aiming to work with the stacks which have already had instrument signature removal and flat fielding etc. We are therefore aiming at this stage to use the LSST stack to coadd these stacks including the necessary warping. We may later want to include the flexibility to ingest the tiles and simply use the stack to warp them to the required skymap.

Each VISTA survey has its own subdirectory. In addition to the imaging data we also store the final catalogeus here which are used for constructing the bootstrap photometric reference in dmu2.

### VHS

The VISTA Hemispher Survey. You can read the full readme [here](./dmu0_VHS/).

### VIKING

The VISTA Kilo degree Infrared Galaxy survey. You can read the full readme [here](./dmu0_VHS/).

### VIDEO

The VISTA Deep Extragactic Observations survey. You can read the full readme [here](./dmu0_VIDEO/).



### VEILS

Work in progress.

### VVV

Work in progress.


## HSC structure

We are using the final HSC PDR2 calibrated exposure 'calexp' patches. This means we will not do any of the ccd processing of HSC images conducted by the stack. We simply want to conduct the detection and measurement stages on them in order to merge with VISTA. We download the full PDR2 Wide and Deep and Ultradeep data [here](./dmu0_HSC/)

## LSST structure

When LSST data becomes available we are expecting it to mirror the HSC calexp structure.

## PanSTARRS

We need a reference catalogue for photometric and astrometric calibration. We will eventually do this with GAIA. We are currently do this with PanSTARRS/GAIA as per the HSC example. 


## Other data sets

Eventually we will store LSST and other data sets here



