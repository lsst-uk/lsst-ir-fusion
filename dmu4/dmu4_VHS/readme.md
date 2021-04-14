# XMM VHS HSC Wide run

This is the first VHS field run alongside the HSC Wide survey data. Eventually we may merge all runs into a single Butler.

![XMM Field ](./figs/xmm_HSC-all_tracts.png)

## Running the code

In the [./slurm](./slurm) directory are multiple array jobs to be submitted to the Slurm queue on IRIS. These are numbered such that each is to be run in turn after the completion of the previous array job:

```
#The first job should be small enough to run direct from a login node
bash 1_setup_butler.sh
#Then we submit an array of jobs to ingest and process the input exposures
qsub 2_processCcd.slurm
#After all those jobs have completed we submit the coadd array job (one 10 CPU job per patch)
qsub 3_coadd.slurm
#After coaddition we submit the array of photometry pipeline jobs (one 1 CPU job per patch)
qsub 4_photopipe.slurm
# Now you need to use the notebooks to check for any failed patches
```
