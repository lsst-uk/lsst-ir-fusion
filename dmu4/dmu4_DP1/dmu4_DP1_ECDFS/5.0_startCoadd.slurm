#!/bin/bash
#!
#! Example SLURM job script for Peta4-IceLake (Ice Lake CPUs, HDR200 IB)
#! Last updated: Sat Jul 31 15:39:45 BST 2021
#!

#!#############################################################
#!#### Modify the options in this section as appropriate ######
#!#############################################################

#! sbatch directives begin here ###############################
#! Name of the job:
#SBATCH -J vidCoadd
#SBATCH -A IRIS-IP005-CPU
#SBATCH -p icelake
#SBATCH --nodes=32
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=250G
#SBATCH --time=12:00:00
#SBATCH --mail-type=ALL
#SBATCH --no-requeue

#! sbatch directives end here (put any additional directives above this line)

#! ############################################################
#! Modify the settings below to specify the application's environment, location
#! and launch method:

#! Optionally modify the environment seen by the application
#! (note that SLURM reproduces the environment at submission irrespective of ~/.bashrc):
. /etc/profile.d/modules.sh                # Leave this line (enables the module command)
module purge                               # Removes all modules still loaded
module load rhel8/default-icl              # REQUIRED - loads the basic environment

#! Insert additional module load commands after this line if needed:

#! Setup LSST Science pipeline environment
source setup.sh

#! Full path to application executable:
application="bps"

#! Run options for the application:
options="submit bpsAllCoadd.yaml"

#! Work directory (i.e. where the job will run):
workdir="$SLURM_SUBMIT_DIR"  # The value of SLURM_SUBMIT_DIR sets workdir to the directory
                             # in which sbatch is run.

#! Are you using OpenMP (NB this is unrelated to OpenMPI)? If so increase this
#! safe value to no more than 76:
export OMP_NUM_THREADS=1

#! The following variables define a sensible pinning strategy for Intel MPI tasks -
#! this should be suitable for both pure MPI and hybrid MPI/OpenMP jobs:
export I_MPI_PIN_DOMAIN=omp:compact # Domains are $OMP_NUM_THREADS cores in size
export I_MPI_PIN_ORDER=scatter # Adjacent domains have minimal sharing of caches/sockets
#! Notes:
#! 1. These variables influence Intel MPI only.
#! 2. Domains are non-overlapping sets of cores which map 1-1 to MPI tasks.
#! 3. I_MPI_PIN_PROCESSOR_LIST is ignored if I_MPI_PIN_DOMAIN is set.
#! 4. If MPI tasks perform better when sharing caches/sockets, try I_MPI_PIN_ORDER=compact.


#! Uncomment one choice for CMD below (add mpirun/mpiexec options if necessary):
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
        #! Create a machine file:
        export NODEFILE=`generate_pbs_nodefile`
        cat $NODEFILE | uniq > machine.file.$JOBID
        echo -e "\nNodes allocated:\n================"
        echo `cat machine.file.$JOBID | sed -e 's/\..*$//g'`
fi

#! When we use a LocalSrunWorkQueue executor, we have to do this because Parsl will
#! look at SLURM_CPUS_ON_NODE which, on Iridis 6, will not be set to what we might
#! expect (all the CPUs available on a node rather than what is in the allocation).
#! So, we will set it to what we want here instead.

TOTAL_CPUS=$(( SLURM_CPUS_PER_TASK * SLURM_NTASKS))

echo -e "\nnumtasks=$SLURM_NTASKS, numnodes=$SLURM_JOB_NUM_NODES, numtasks_per_node=$SLURM_NTASKS_PER_NODE, numcpus=$TOTAL_CPUS (OMP_NUM_THREADS=$OMP_NUM_THREADS)"

echo -e "\nExecuting command:\n==================\n$CMD\n"

export SLURM_CPUS_PER_TASK=2
export SLURM_CPUS_ON_NODE=$SLURM_CPUS_PER_TASK
echo "Executing with $SLURM_CPUS_PER_TASK CPUs per node"

eval $CMD

# Prints a task and error summary. If any tasks failed, then this will send a non-zero
# exit code to Slurm
OUTPUT_FILE=$(scontrol show job "$SLURM_JOB_ID" | awk -F= '/StdOut=/{print $2}')
python print_errors.py $OUTPUT_FILE
