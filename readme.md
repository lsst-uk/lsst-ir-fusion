# LSST IR fusion

This repository defines the database structure for the upcoming combined Vera C. Rubin Observatory Legacy Survey of Space and Time (LSST) and Visible and Infrared Survey Telescope for Astronomy (VISTA) near infrared data product. This will provide pixel matched images and multiband catalogues. A preliminary data release will be produced using the Hyper SuprimeCam imaging and catalogues as a precursor to the LSST ten year survey due to start in 2023. The raw data is not stored in Git but there are various notebooks, code, and data descriptions here which, together with the raw data, define the data release. The full data product is currently under development and not publicly available. 

## Installation

The code is this repository makes use of the LSST stack and the bespoke obs_vista package which tells the LSST stack how to interact with VISTA data. The installation of both of these is described in the obs_vista package:

https://github.com/lsst-uk/obs_vista

That should then permit running the notebooks in the database here. 


## Data structure

Each folder contained here will have a corresponding data folder not stored on GitHub. Each stage of the processing is divided in to a seperate Data Management Unit (DMU) folder:

 DMU               |  Contents
-------------------|------------------------------------------
 [DMU0](dmu0)      |  Images and catalogues which are inputs to data products produced here.
 [DMU1](dmu1)      |  Summaries and stats for raw data in DMU0
 [DMU2](dmu2)      |  Constructing photometric and astrometric reference catalogues
 [DMU3](dmu3)      |  SExtractor baseline catalogues
 [DMU4](dmu4)      |  LSST pipeline catalogues
 [DMU5](dmu5)      |  Comparisons and diagnostics



## Tiling, warping and pixel spaces

The basic tiles are set by the HSC public imaging product which should be similar to the final LSST version. This tiling of the sky into 'tracts' and 'patches' is described in the HSC release pages.

## Basic procedure

After installation of the LSST stack and obs_vista (instructions with the obs_vista package) and cloning this repository you need to do the following for a standard run:

### 1. Put raw data in DMU0

As a minimum you will need the VISTA imaging of interest, the HSC public processed data of interest, the public PanSTARRS photometric and astrometric catalogues used to calibrate HSC, the 2MASS point source catalogue.

### 2. Create data summaries in DMU1

We run some simple data trawls in DMU1 in order to find overlapping areas for the VISTA images with the relevant SkyMap patches for a given HSC survey. You need to create a list of VISTA images, their corresponding HSC patches, PanSTARRS 'shards' to make the PanSTARRS-2MASS reference catalogue.

### 3. Create the reference catalogues in DMU2

We merge the PanSTARRS and 2MASS catalogues using a positional cross match and write it to a format which can be ingested by the LSST stack

### 4. Run the photometry pipeline to create the final Butler repository in DMU4

This stage consists of many steps which are documented in DMU4. In the final DMU4 folder there are numerous repositories for various different data sets and fields. These repositories should follow the structure of the public HSC/LSST data releases as far as possible. This should allow them to incorporated with other data sets created with the LSST stack using the same procedure.




