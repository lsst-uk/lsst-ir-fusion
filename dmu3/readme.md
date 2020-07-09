# LSST IR fusion

This is a first step towards combining LSST and VISTA IR imaging. In the first instance we are running Sextractor on HSC and VISTA imaging in dual image mode to create benchmarks against which to compare similar catalogues produced with the LSST stack. These HSC-VISTA catalogues will themselves be an end product but the final aim is for the code to be ready to run as soon as the first LSST coadd images start to arrive in 2021(?).

## Technical information

We are using data stored on the DIRAC system which manages machines in Cambridge. I login with 

ssh -l ir-shir1 login.hpc.cam.ac.uk

using the password which can be found at https://protect-eu.mimecast.com/s/vFOUCN05NTM9j8oI4k-TC?domain=safe.epcc.ed.ac.uk

## Data structure

This code is developed on a personal laptop on individual tiles. Final processing should be run on individual tiles so each tile can be sent to a queing system as an individual job. 

1. [data.yml](a file specifying the location of raw image data on the DIRAC machine)
2. [data_local.yml](a file overiding the above for local development)

## Tiling

The basic tiles will be set by the HSC public imaging product which should be similar to the LSST version. 

Questions: 

1) do tiles overlap? how do we deal with objects at the edge of the tile?
2) Do can we specify these tiles? RA-dec of corners? HealPix?

## Detection images

The code should be capable of running on any set of detection images. To begin we use i band HSC and Ks band VISTA detection images. Eventually we may want to apply all and use flags in a combined catalogue to specify which bands a given object is detected in.