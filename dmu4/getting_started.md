# Getting started with the development of the LSST IR fusion pipeline

In this document I will give some general advice on getting started with developing the LSST IR fusion pipeline and provide soome ideas for future development.

## Conduct a small local run

The first thing you should try to do is conduct a small test run on your laptop wioth the latest version of the LSST Science Pipelines. 

## Conduct a rerun of the SXDS VIDEO data on CSD3

After you have confirmed that the code will run on your laptop you shoudl attempt a rerun of the SXDS VIDEO run on the CSD3 system using the Batch Processing Service with the parsl backend and the Slurm queing system.

## Future developments

1) Move to postgres based Butler. This should be more resilient and scale better.
2) Move to S3 storage. This should be supported by default and the bulk of the new storage we are getting is going to be S3 based so try to use that.
3) Produce new GAIA 2 based reference catalogues with just the VISTA photometry. This is relatively straightforward using the code in DMU2 but needs to be parellelised using Slurm arrays as deploed in DMU5.
4) Move to the new LSST sky map when available. The sky map format is due to be overhauled so the pipelines will need to be updated to deal with the new format.


## General advice:

1) Try to run everying on CSD3 as a Slurm script.
    Any job that runs more than a minute has the risk of being interuped when submitted at the shell prompt. It is therefore important to try to submit anything beyond very simple operations to the Slurm queue. In particular anything that writes to the Butler can currupt the database if interupted so is best submitted as a Slurm job.
2) Backup the sqlite file in the Butler regularly.
    It is quite easy for the Butler database file to be corrupted beyond repair. Having a simple backup of the sqlite file will allow it to be fixed by simply returning the backedup file. You may then find you have files in the Butler that are not in the database but you won't have broken the whoel database.
