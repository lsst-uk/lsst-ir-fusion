# LSST IR fusion

This is a first step towards combining LSST and VISTA IR imaging. In the first instance we are running Sextractor on HSC and VISTA imaging in dual image mode to create benchmarks against which to compare similar catalogues produced with the LSST stack. These HSC-VISTA catalogues will themselves be an end product but the final aim is for the code to be ready to run as soon as the first LSST coadd images start to arrive in 2023(?).

## Installation

The standard LSST pipeline is installed according to the instructions here:

https://pipelines.lsst.io/install/newinstall.html

These instructions worked on a local mac and on hpc.cam.ac.uk. However, in order to develop the obs_vista package we will need to install the LSST stack using the lsstsw method:

https://pipelines.lsst.io/install/lsstsw.html

You will need to install jupyter notebooks within the LSST shell to use them

```Shell
$ conda install notebook

```

You will also need to activate the LSST shell anytime you use the software and add the command line commands to your shell

```Shell
$ source loadLSST.bash # load the lsst shell
$ setup lsst_distrib   # add commands to shell
```

For the baseline tests we used SExtractor and SWarp. The installation instructions for which are here:

https://sextractor.readthedocs.io/en/latest/Installing.html

and 

https://www.astromatic.net/software/swarp

Eventually this code will make use of the obs_vista package which is currently under development:

https://github.com/raphaelshirley/obs_vista

This will tell the LSST stack how to interact with the VISTA database structure and raw files.


## Data structure

This code is developed on a personal laptop on individual tiles. Final processing should be run on individual tiles so each tile can be sent to a queing system as an individual job. 

1. [data.yml](a file specifying the location of raw image data on the DIRAC machine)
2. [data_local.yml](a file overiding the above for local development)

Each stage of the processing is divided in to a seperate Data Management Unit (DMU) folder:

 DMU               |  Contents
-------------------|------------------------------------------
 [DMU1](dmu1)      |  Summarise the imaging data
 [DMU2](dmu2)      |  Swarping the VISTA data to HSC/LSST pixel base
 [DMU3](dmu3)      |  SExtractor baseline catalogues
 [DMU4](dmu4)      |  LSST pipeline catalogues
 [DMU5](dmu5)      |  Comparisons and diagnostics


## Tiling, warping and pixel spaces

The basic tiles will be set by the HSC public imaging product which should be similar to the LSST version. The HSC tiles overlap. We need to decide whether to warp the VISTA images to HSC/LSST tiles or whether we can merge detection catalogues before measurement and leave the VISTA pixel space as it is. If we want to produce chi squared images we will need to warp the VISTA images.

## Detection images

The code should be capable of running on any set of detection images. To begin we use i band HSC and Ks band VISTA detection images. Eventually we may want to make detection catalogues from every band and or a chi squared image and use flags in a combined catalogue to specify which bands a given object is detected in.
