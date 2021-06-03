# DMU4 LSST pipeline catalogues

This folder contains the main results from the project. Here we will store the final multiband detected HSC-VISTA and eventually LSST-VISTA catalogues and processed and coadded images in Butler repositories. All the Butler repositories are stared in 'data' folders.

The pipeline is based on the standard HSC processing described in the introductory tutorial

https://pipelines.lsst.io/getting-started/data-setup.html

In the 'dmu4_Example' folder we run the pipeline on a minimal VISTA-Ks^VISTA-Y^HSC-R which is executed by downloading all the requisite image files and running the shell script here with executes all the LSST stack command line tasks. The final datasets are stored in the directories here for different pairs of VISTA and HSC surveys.

- [./dmu4_Example](./dmu4_Example) Minimal example training data set in SXDS for pipeline development.
- [./dmu4_VIDEO](./dmu4_VIDEO) The SXDS field of the HSC PDR2 DUD survey with the VIDEO survey with multiple sets of detection catalogues.
- [./dmu4_VHS](./dmu4_VHS) VHS survey processing. For now only on HSC PDR2 coverage.
- [./dmu4_VIKING](./dmu4_VIKING) VIKING survey processing run. For now this only over HSC PDR2 coverage.

In the future we plan to produce on the Slurm machinery in the individual folders and then preduce a single Butler in this top level directory. 
For now we use a separate Butler for every survey run.

## Slurm files
This directory also contains the scripts used to generate 'slurm' files for submitting jobs to the IRIS HPC. These can be modified to produce job scripts on other platforms.

There are a number of decisions made in the notebooks regarding which stacks to include in coadds. See the discussion of ESOGRADE values in the headers:

http://casu.ast.cam.ac.uk/surveys-projects/vista/data-processing/eso-grades

## Example commands

All the steps might loosely be executed after all the appropriate files are put in place  on IRIS with the following commands:

```Shell
#Setup a fresh Butler and copy the requisite reference objects
bash setup.sh
#Submit all the image processing jobs
qsub 1_ProcessCcd.slurm
#Wait for all jobs to complete
qsub 2_Coadd.slurm
#Wait for all coadd jobs to complete
qsub 3_Photopipe.slurm
#Run diagnostics and final catalogue production in DMU5
```
