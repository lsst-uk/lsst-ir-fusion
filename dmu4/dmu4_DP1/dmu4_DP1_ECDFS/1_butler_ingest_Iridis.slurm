#!/bin/bash

#!#############################################################
#!#### Modify the options in this section as appropriate ######
#!#############################################################

#SBATCH --job-name=ingest
#SBATCH --partition=batch
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=32G
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=1
#SBATCH --no-requeue
#SBATCH --mail-type=ALL
#SBATCH --output=%x-%j.out


#! Full path to application executable:
application="./butler_ingest.sh"

#! Run options for the application:
options=""

#! Work directory (i.e. where the job will run):
workdir="$SLURM_SUBMIT_DIR"

#! Are you using OpenMP (NB this is unrelated to OpenMPI)? If so increase this
#! safe value to no more than 32:
export OMP_NUM_THREADS=1

#! Choose this for a pure shared-memory OpenMP parallel program on a single node:
#! (OMP_NUM_THREADS threads will be created):
CMD="$application $options"

###############################################################
### You should not have to change anything below this line ####
###############################################################

cd $workdir
echo -e "Changed directory to `pwd`.\n"

JOBID=$SLURM_JOB_ID

echo -e "JobID: $JOBID\n======"
echo "Time: `date`"
echo "Running on master node: `hostname`"
echo "Current directory: `pwd`"

if [ "$SLURM_JOB_NODELIST" ]; then
    echo -e "\nNodes allocated:\n================"
    echo "$SLURM_JOB_NODELIST"
fi

echo -e "\nnumtasks=$SLURM_NTASKS, numnodes=$SLURM_NNODES, tasks_per_node=$SLURM_NTASKS_PER_NODE \
    tasks_per_core=$SLURM_NTASKS_PER_CORE cpus_per_task=$SLURM_CPUS_PER_TASK mem_per_cpu=$SLURM_MEM_PER_CPU \
    (OMP_NUM_THREADS=$OMP_NUM_THREADS)"

echo -e "\nExecuting command:\n==================\n$CMD\n"

#! When we use a LocalSrunWorkQueue executor, we have to do this because Parsl will
#! look at SLURM_CPUS_ON_NODE which, on Iridis 6, will not be set to what we might
#! expect (all the CPUs available on a node rather than what is in the allocation).
#! So, we will set it to what we want here instead.
export SLURM_CPUS_ON_NODE=$SLURM_CPUS_PER_TASK


#! Run the LSST Science pipeline
eval $CMD
