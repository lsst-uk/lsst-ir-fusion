DP1 VIRCAM CIRCULAR-APERTURE CORRELATED-NOISE CORRECTION — CSD3
================================================================

Purpose
-------
Apply empirical, band-dependent aperture-noise correction factors measured
from blank-sky apertures in the DP1 ECDFS VIRCAM coadds. The analysis producing
these factors is maintained separately in DP1_Correlated_Noise_RSP.ipynb.

This directory implements the catalogue correction only. It does not repeat
the noise estimation, generate the reduced photometric catalogue, or create
the later unified optical + corrected NIR TAGGED collection.

Files to keep under version control
-----------------------------------
  apply_dp1_aperture_noise.py          Butler correction and verification
  slurm_apply_dp1_aperture_noise.sh    CSD3 production SLURM job
  DP1_aperture_noise_calibration.csv   35 measured band/radius factors
  README_CSD3.txt                     This file

No separate test SLURM file is required. The Python script still supports
--mode test for optional small-scale checks. Do not commit SLURM output,
JSONL audit logs, FITS data products, or transient test files.

Input Butler repository and datasets
------------------------------------
Repository:
  /home/ir-sare1/rds/rds-iris-ip005/Elham/lsst-ir-fusion/
  dmu4/dmu4_DP1/dmu4_DP1_ECDFS/data

Original INPUT RUN (read-only):
  u/ir-sare1/DRP/videoMultiVisits/20260914T000055Z

Dataset types (same for input and output):
  deepCoadd_meas
  deepCoadd_forced_src

Sky map:
  lsst_cells_v1

VIRCAM bands:
  Z, Y, J, H, K

Corrected OUTPUT RUN:
  u/ir-sare1/DRP/videoMultiVisits_CorrNoise/20261022

The corrected catalogues are written to this new RUN, not the original one.
No new dataset types are registered. When retrieving these datasets, specify
an explicit collection: the dataset type and data ID alone are insufficient
to distinguish original and corrected versions.

Example:
  corrected = butler.get(
      "deepCoadd_meas", dataId=did,
      collections=["u/ir-sare1/DRP/videoMultiVisits_CorrNoise/20261022"],
  )

Correction method
-----------------
For each band and aperture radius, multiply the EXISTING
base_CircularApertureFlux_*_instFluxErr field by the corresponding median
factor in DP1_aperture_noise_calibration.csv.

Radii (pixels): 3, 4.5, 6, 9, 12, 17, 25.
Total correction factors: 5 bands x 7 radii = 35.

Only finite, strictly positive uncertainty values are multiplied. Zero,
negative, NaN and infinite values are left unchanged. Values are assigned
back into the original column dtype; no fields are added or renamed. Fluxes,
source IDs, astrometry, quality flags, and other photometric uncertainties
are not intentionally modified.

Validation and preservation
---------------------------
The implementation:
  * Makes a deep copy of each SourceCatalog.
  * Verifies that the seven requested fields exist and are floating-point.
  * Checks every catalogue field for exact expected values, first in memory
    and again after writing to and reading back from Butler.
  * Checks source counts, field names/order, field keys/types, units and
    aliases. Samples 25 footprints per catalogue for geometric consistency.
  * Preserves ordinary table metadata. FITS-round-trip changes to schema
    free-text documentation and Butler-managed provenance are allowed, as
    verified during development; these are not scientific value changes.
  * Supports restarting a partial job by checking existing output datasets
    for correctness and skipping them rather than overwriting them.
  * Writes optional JSONL audit records with original and corrected dataset
    UUIDs, source/output RUNs, data IDs, and calibration-file SHA256.

Original processing-input provenance cards are not automatically copied to
the new Butler dataset; the audit log records source-to-output provenance.

Running on CSD3
---------------
Activate the project LSST environment, including setup lsst_distrib when
working interactively. Run from the directory containing this script and
DP1_aperture_noise_calibration.csv.

1. Optional read-only inventory (no Butler changes):

   python apply_dp1_aperture_noise.py --mode plan \
     --calibration DP1_aperture_noise_calibration.csv

2. Production processing (submit from this directory):

   sbatch slurm_apply_dp1_aperture_noise.sh

The SLURM script uses the project setup.sh and writes the results to the
output RUN above. It writes an append-only audit log named
DP1_apNoise_production_audit.jsonl in the submission directory.

3. Check the job log and Butler inventory. A completed production run ends:

   FINISHED 810 verified catalogues

Expected output inventory:
  deepCoadd_meas         406 datasets (Z=42, Y=91, J=91, H=91, K=91)
  deepCoadd_forced_src   404 datasets (Z=42, Y=89, J=91, H=91, K=91)

The two missing Y-band forced datasets are missing from the original input
collection; the correction script does not create missing source catalogues.

Actual DP1 processing outcome (22 October 2026)
------------------------------------------------
Completed on CSD3 using the same dataset types in the separate output RUN:
  measured: 406/406 written and verified
  forced:   404/404 written and verified
  total:    810/810 verified

The calibration CSV used for this run has SHA256:
  4f2765c64b8d5cdcc7a0ecbda32eed6df11ac3fadbbbe532d8e79199d4c04bf9

The corrected catalogues were subsequently combined with the unchanged
optical catalogues in a separate TAGGED-collection step, documented and
version-controlled independently.

Scientific limitations
----------------------
The factors are empirical corrections to circular-aperture background-noise
estimates, not a full source-by-source uncertainty model. They represent
band-level medians across eligible patches. Patch-to-patch variation, fewer
independent blank-sky samples at larger radii (especially radius 25), and
possible source-dominated noise contributions for bright objects remain
limitations. See the RSP calibration notebook for the validation, bootstrap
intervals, spatial diagnostics and hold-out results.

Do not use these factors for PSF, Kron, CModel or other non-circular-aperture
uncertainty fields.
