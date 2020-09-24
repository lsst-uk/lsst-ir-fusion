# DMU4 LSST pipeline catalogues

This folder contains the main results from the project. Here we will store the final multiband detected HSC-VISTA and eventually LSST-VISTA catalogues and processed and coadded images in Butler repositories. All the Butler repositories are stared in 'data' folders.

The pipeline is based on the standard HSC processing described in the introductory tutorial

https://pipelines.lsst.io/getting-started/data-setup.html

In the 'dmu4_Example' folder we run the pipeline on a minimal VISTA-Ks^VISTA-Y^HSC-R which is executed by downloading all the requisite image files and running the shell script here with executes all the LSST stack command line tasks. The final datasets are stored in the directories here for different pairs of VISTA and HSC surveys.

- [./dmu4_Example](./dmu4_Example) Minimal example training data set in SXDS for pipeline development.
- [./dmu4_SXDS](./dmu4_SXDS) The SXDS field of the HSC PDR2 DUD survey with the VIDEO survey with multiple sets of detection catalogues.
- [./dmu4_VHS](./dmu4_VHS) A pure VISTA reprocessing of the VHS survey? This will be rerun in LSST with VISTA in due course.
- VIDEO/HSC-wide?
- Individual folders for each HSC field?

## Slurm files
This directory also contains the scripts used to generate 'slurm' files for submitting jobs to the IRIS HPC. These can be modified to produce job scripts on other platforms.