#!/bin/bash
#SBATCH --job-name=DP1_apNoise
#SBATCH --account=IRIS-IP005-CPU
#SBATCH --partition=cclake
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --time=24:00:00
#SBATCH --output=DP1_apNoise_%j.out
#SBATCH --error=DP1_apNoise_%j.err
#SBATCH --no-requeue

set -euo pipefail

# Submit from the folder containing this SLURM script, the Python script,
# and DP1_aperture_noise_calibration.csv.
cd "$SLURM_SUBMIT_DIR"
PROJECT_DIR="/home/ir-sare1/rds/rds-iris-ip005/Elham/lsst-ir-fusion/dmu4/dmu4_DP1/dmu4_DP1_ECDFS"
REPO="$PROJECT_DIR/data"

# CSD3 environment, following the project's existing setup.sh.
source /etc/profile.d/modules.sh
module purge
module load rhel8/default-icl
set +u
source "$PROJECT_DIR/setup.sh"
set -u

# IMPORTANT: test this script interactively with --mode plan and --mode test
# before submitting the production job.
OUTPUT_RUN="u/ir-sare1/DRP/videoMultiVisits_CorrNoise/20261022"

python -u apply_dp1_aperture_noise.py \
  --mode full \
  --repo "$REPO" \
  --calibration "$SLURM_SUBMIT_DIR/DP1_aperture_noise_calibration.csv" \
  --run "$OUTPUT_RUN" \
  --types measured forced \
  --audit-log "$SLURM_SUBMIT_DIR/DP1_apNoise_production_audit.jsonl"
