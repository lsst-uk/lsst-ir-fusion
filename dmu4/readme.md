# DMU4 LSST pipeline catalogues

This folder contains the main results from the project. Here we will store the final multiband detected HSC-VISTA and eventually LSST-VISTA catalogues and processed and coadded images in Butler repositories. All the Butler repositories are stared in 'data' folders.

The pipeline is based on the standard HSC processing described in the introductory tutorial

https://pipelines.lsst.io/getting-started/data-setup.html

In the 'dmu4_Example' folder we run the pipeline on a minimal VISTA-Ks^VISTA-Y^HSC-R which is executed by downloading all the requisite image files and running the shell script here with executes all the LSST stack command line tasks. The final datasets are stored in the directories here for different pairs of VISTA and HSC surveys.

- [./dmu4_Example](./dmu4_Example) Minimal example training data set in SXDS for pipeline development.
- [./dmu4_VIDEO](./dmu4_VIDEO) The SXDS field of the HSC PDR3 DUD survey with the VIDEO survey with multiple sets of detection catalogues.
- [./dmu4_VHS](./dmu4_VHS) VHS survey processing. For now only on HSC PDR3 coverage.
- [./dmu4_VIKING](./dmu4_VIKING) VIKING survey processing run. For now this only over HSC PDR3 coverage.

In the future we plan to produce on the Slurm machinery in the individual folders and then preduce a single Butler in this top level directory. 
For now we use a separate Butler for every survey run.

## Slurm files
This directory also contains the scripts used to generate 'slurm' files for submitting jobs to the IRIS HPC. These can be modified to produce job scripts on other platforms.

There are a number of decisions made in the notebooks regarding which stacks to include in coadds. See the discussion of ESOGRADE values in the headers:

http://casu.ast.cam.ac.uk/surveys-projects/vista/data-processing/eso-grades

### Slurm config

We are using the pipe drivers which can be parellised. In general we are submitting to only one node. The coaddDriver.py jobs are sent to 10 cpus on one node partly to ensure there is enough memory. The multiBandDriver.py jobs can be sent to 16 cpus to avoid the majority timing out. The scripts are set up to first test if the job has been run by checking if the final files are present. This means that slurm jobs can be reletaively safely resubmitted without wasting large amounts of cpu time on rerunning jobs.

### Running notes

The slurm files must be run sequentially following completion of earlier stages. I believe it is possible to delete intermediate products but you cannot remove the whole rerun the config must be left in place. It is also necessary for the skymap to be present for example so take care when deleting intermediate directories.

## Example commands

All the steps might loosely be executed after all the appropriate files are put in place  on IRIS with the following commands:

```Shell
#Setup a fresh Butler and copy the requisite reference objects
bash 1_butler_setup.sh
#Ingest the exposures
qsub 1_Ingest.slurm
#Submit all the image processing jobs
qsub 2_ProcessCcd.slurm
#Wait for all jobs to complete
qsub 3_Coadd.slurm
#Wait for all coadd jobs to complete
qsub 4_Photopipe.slurm
#Run diagnostics and final catalogue production in DMU5
```

Occasionally the resources given to each patch or image in the slurm file need to be increased for failed patches or images. They should be set such that the majority (>95%) pass first time but checks must be made to see any that require increased resources and rerunning.