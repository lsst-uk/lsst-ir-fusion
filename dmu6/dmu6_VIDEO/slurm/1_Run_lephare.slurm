#!/bin/bash
#! This line is a comment
#! Make sure you only have comments and #SBATCH directives between here and the end of the #SBATCH directives, or things will break
#! Name of the job:
#SBATCH -J SXDS_photoz
#! Account name for group, use SL2 for paying queue:
#SBATCH -A IRIS-IP005-CPU
#! Output filename:
#! %A means slurm job ID and %a means array index
#SBATCH --output=SXDS_Make_cat_%A_%a.out
#! Errors filename:
#SBATCH --error=SXDS_Make_cat_%A_%a.err

#! Number of nodes to be allocated for the job (for single core jobs always leave this at 1)
#SBATCH --nodes=1
#! Number of tasks. By default SLURM assumes 1 task per node and 1 CPU per task. (for single core jobs always leave this at 1)
#SBATCH --ntasks=1
#! How many many cores will be allocated per task? (for single core jobs always leave this at 1)
#SBATCH --cpus-per-task=1
#! Estimated runtime: hh:mm:ss (job is force-stopped after if exceeded):
#SBATCH --time=20:00:00
#! Estimated maximum memory needed (job is force-stopped if exceeded):
#! RAM is allocated in ~5980mb blocks, you are charged per block used,
#! and unused fractions of blocks will not be usable by others.
#! coadding VIDEO needs ~ 5 cpus worth of memory SBATCH --mem=5980mb
#! Submit a job array with index values between 0 and 31
#! NOTE: This must be a range, not a single number (i.e. specifying '32' here would only run one job, with index 32)
#! 0-218
#SBATCH --array=0-218

#! This is the partition name.
#SBATCH -p cclake

#! mail alert at start, end and abortion of execution
#! emails will default to going to your email address
#! you can specify a different email address manually if needed.
##SBATCH --mail-type=ALL

#! Don't put any #SBATCH directives below this line

#! Modify the environment seen by the application. For this example we need the default modules.


#! The variable $SLURM_ARRAY_TASK_ID contains the array index for each job.
#! In this example, each job will be passed its index, so each output file will contain a different value
echo "This is photoz job" $SLURM_ARRAY_TASK_ID

#! Command line that we want to run:
#! /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst-ir-fusion/dmu5/dmu5_VIDEO/slurm/make_cat.sh $SLURM_ARRAY_TASK_ID /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst-ir-fusion/dmu4/dmu4_VIDEO/slurm/sxds_patch_job_dict_219.json
source /home/ir-shir1/rds/rds-iris-ip005/ras81/lsst-ir-fusion/setup.sh
python make_cat.py $SLURM_ARRAY_TASK_ID \
    ../../../dmu4/dmu4_VIDEO/slurm/sxds_patch_job_dict_219.json
varArray="$(python jobDict.py $SLURM_ARRAY_TASK_ID ../../../dmu4/dmu4_VIDEO/slurm/sxds_patch_job_dict_219.json)"
varArray=($varArray)
tract=${varArray[0]}
patch=${varArray[1]}
let patchNew=${patch:0:1}+9*${patch:2:2}
echo "Tract: " $tract ", patch: " $patch ", newPatch: " $patchNew

#patches from dict are still in old format
$LEPHAREDIR/source/zphota \
    -c ../config/photoz.para \
    -CAT_IN ../data/$tract/$patchNew/photoz.in \
    -CAT_OUT ../data/$tract/$patchNew/zphot_short.out \
    -PARA_OUT ../config/output.para \
    -ZPHOTLIB VISTA_COSMOS_FREE,ALLSTAR_COSMOS,QSO_COSMOS \
    -ADD_EMLINES 0,100 \
    -AUTO_ADAPT NO \
    -Z_STEP 0.04,0,6
