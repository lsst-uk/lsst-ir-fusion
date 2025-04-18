# DMU4 LSST pipeline catalogues

This folder contains the main results of the project. Here, we will store the final multiband detected HSC-VISTA and eventually LSST-VISTA catalogues and processed and coadded images in Butler repositories. All the Butler repositories are started in 'data' folders.

The pipeline is based on the standard HSC processing described in the introductory tutorial

https://pipelines.lsst.io/getting-started/data-setup.html

In the 'dmu4_Example' folder, we run the pipeline on a minimal VISTA-Ks^VISTA-Y^HSC-R, which is executed by downloading all the requisite image files and running the shell script here with executes all the LSST stack command line tasks. The final datasets are stored in the directories here for different pairs of VISTA and HSC surveys.

- [./dmu4_Example](./dmu4_Example) Minimal example training data set in SXDS for pipeline development.
- [./dmu4_VIDEO](./dmu4_VIDEO) The SXDS field of the HSC PDR3 DUD survey with the VIDEO survey with multiple sets of detection catalogues.
- [./dmu4_VHS](./dmu4_VHS) VHS survey processing. For now only on HSC PDR3 coverage.
- [./dmu4_VIKING](./dmu4_VIKING) VIKING survey processing run. For now, this is only over HSC PDR3 coverage.

In the future, we plan to produce on the Slurm machinery in the individual folders and then produce a single Butler in this top-level directory. 
For now, we use a separate Butler for every survey run.

Installing the parsl software in order to run at scale is described in [gen3_workflow.md](gen3_workflow.md).

## Slurm files
This directory also contains the scripts used to generate 'slurm' files for submitting jobs to the IRIS HPC. These can be modified to produce job scripts on other platforms.

There are a number of decisions made in the notebooks regarding which stacks to include in coadds. See the discussion of ESOGRADE values in the headers:

http://casu.ast.cam.ac.uk/surveys-projects/vista/data-processing/eso-grades

### Slurm config

We are using the pipe drivers, which can be paralleled. In general, we are submitting to only one node. The coaddDriver.py jobs are sent to 10 cpus on one node partly to ensure there is enough memory. The multiBandDriver.py jobs can be sent to 16 CPUs to avoid the majority timing out. The scripts are set up to first test if the job has been run by checking if the final files are present. This means that Slurm jobs can be relatively safely resubmitted without wasting large amounts of CPU time on rerunning jobs.

### Running notes

The Slurm files must be run sequentially following the completion of earlier stages. I believe it is possible to delete intermediate products, but you cannot remove the whole rerun; the config must be left in place. It is also necessary for the skymap to be present, for example, so take care when deleting intermediate directories. All deletion must be performed with a butler command and not a straightforward delete to ensure the database is updated. These deletions should be submitted as Slurm jobs because they can take a long time, and if interrupted, the SQLite database may be corrupted. 

I recommend regularly backing up the SQLite database file in case it is corrupted. It can also be cleaned in the case of an interrupted write using:

```Shell
sqlite3 ge3.sqlite 'VACUUM;'
```

## Example commands

All the steps might loosely be executed after all the appropriate files are put in place on IRIS with the following commands run inside a given slurm folder above:

```Shell
# Setup a fresh Butler and ingest the exposures
qsub 1_butler_ingest.slurm
# Submit all the single-frame processing jobs
qsub 2.0_startSingleFrame.slurm
# Wait for the job to complete using the following command to check on current jobs
qstat -u $USER
# If the job does not finish in 36 hours, it will need to be restarted - the run ID will have to be changed in the restart script
qsub 2.1_restartSingleFrame.slurm
# Submit all the Source Calibration jobs
qsub 3.0_startCalibrate.slurm
# Submit all the coadd jobs
qsub 4.0_startCoadd.slurm 
# Ingest the optical images and detections
qsub 5_ingestHSC.slurm
#  Submit all the final photometry jobs
qsub 6.0_startMultiVisit.slurm  
# Run diagnostics and final catalogue production in DMU5
```

Occasionally, the resources given to each patch or image in the slurm file need to be increased for failed patches or images. They should be set such that the majority (>95%) pass the first time, but checks must be made to see any that require increased resources and rerunning.

The jobs will often end without being completed, so output files must be inspected to check that the quantum graph has completed and you can move on to the next stage.

## Run details

We have conducted numerous tests and production runs since the start of the project in 2020.

### P2022.3

This is the first full wide area run of VHS, VIKING, and VIDEO overlapping with the HSC PDR3 Wide survey. As of December 2022, this run is underway. This will hopefully lead to the final data set presented by phase B of the project, which ends in March 2023. This will be transferred to the UK RSP for further testing and presentation of the data for science purposes.

During this run, many of the HSC detections and image files turned out to be small error files downloaded by wget. These were then removed from the import to prevent them from breaking certain tasks. The download should be completed after first deleting these error files.

### P2022.2

This was the second full run of VIDEO on the HSC PDR3 DUD field SXDS. This produced the first full set of imaging and catalogues that were sent to the UK RSP for testing. It fixed issues with completeness in the run P2022.1, where patches were missing and patches with partial coverage by the Z band were leading to deblending failures.

### P2022.1

This was the first full-scale VIDEO run conducted with the gen3 pipeline and confidence map integration. Following this run we found issues with the reference catalogue photometry due to using the incorrect aperture correction.

### P2021.1 

Second prototype run April 2021. We conducted a full overlap run in April 2021. This will likely be the last run using the gen 2 Butler.
This run is all band-selected and includes Kron, CModel, and convolved aperture fluxes.

### P2020.1 

First prototype December 2020. We conducted the first run in December 2020. This version was only VISTA Ks band detected.
In that regard and some other crucial ways, it differs from the later runs, which are all band detected.
Later runs also had changes to the photometric reference catalogues and additional measurements included.
