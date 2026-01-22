## DP1 Multi-band Coadd Catalog Production

This directory contains scripts to build **science-ready, multi-band 
photometric catalogs** from LSST DP1 coadd data using the Gen3 Butler.
The workflow produces **per-patch reduced catalogs** and then **merges them 
into a single full DP1 catalog**.

The codes supports **ComCam (u,g,r,i,z,y)** and **VISTA/VIRCAM (Z,Y,J,H,K)** 
data and is designed to run efficiently on HPC systems using job arrays.

---

### Overview of the Workflow

#### Step 1 — Per-patch catalog construction (`make_cat.py`)
For each `(tract, patch)` pair:

1. Read **measurement catalogs** (`deepCoadd_meas`)
2. Read **forced photometry catalogs** (`deepCoadd_forced_src`)
3. Read **coadd calibration images** (`deepCoadd_calexp`)
   - ComCam and VIRCAM use different collections
4. Convert instrumental fluxes to:
   - magnitudes
   - magnitude errors
   - nanojansky fluxes
5. Merge all bands into a single catalog per patch
6. Write:
   - optional per-band CSV catalogs
   - a **reduced per-patch catalog** (FITS + CSV)

---

#### Step 2 — Full catalog merge (`make_full_catalog.py`)
After all patches finish:

1. Locate all per-patch reduced catalogs
2. Vertically stack them into one table
3. Clean invalid floating-point values
4. Write a single **survey-level reduced catalog**

---

### Contents

1. make_cat.py # Per-patch catalog creation
2. make_full_catalog.py # Merge all patches into one catalog
3. DP1-patches.json # Mapping from job IDs to (tract, patch)
4. run_makecat.slurm

---

### Run per-patch catalog creation

python make_cat.py ${SLURM_ARRAY_TASK_ID} DP1-patches.json

Each array task:
* processes one (tract, patch)
* runs independently
* writes results to data/


---

### Patch Handling
* Patches are treated as integer IDs (DP1 uses a 10×10 grid)
* Patch coordinates (x,y) are converted via:
  
  `patch_id = x + 10*y`
* Integer patch IDs can be passed directly.

---

### Photometric Calibration
* Magnitudes and fluxes are computed using the `PhotoCalib` from `deepCoadd_calexp`
* Zeropoints are read from calibration metadata

---

### Output Structure

```
data/
├── ComCam_g/
│   └── <tract>/<patch>/
│       ├── *_measCat.csv
│       └── *_forcedCat.csv
├── VIRCAM_K/
│   └── <tract>/<patch>/
├── merged/
│   └── <tract>/<patch>/
│       ├── <tract>_<patch>_reducedCat.fits
│       └── <tract>_<patch>_reducedCat.csv
└── full_reduced_cat_DP1_YYYYMMDD.fits

```

---

### Configuration: What Users Must Change

**1. Butler repository path**

In both scripts:

```BUTLER_LOC = "../../dmu4/dmu4_DP1/dmu4_DP1_ECDFS/data"```


Change this to point to your Butler repository.

**2. Collection names (CRITICAL)**

Set these according to your processing runs:
```
COLL_MEAS_FORCED = "u/ir-sare1/DRP/videoMultiVisit/20260119T222850Z"
COLL_CALEXP_VIRCAM = "u/ir-sare1/DRP/videoCoaddDetects/20260119T111844Z"
COLL_CALEXP_COMCAM = "ComCam/deepCoadd_results"
```

`COLL_MEAS_FORCED` must contain: `deepCoadd_meas` and `deepCoadd_forced_src`

`COLL_CALEXP_*` must contain: `deepCoadd_calexp`

**3. Output directory**

Default: `DATA = "data"`

**4. Bands**

  Modify if needed:

  `comcamBands = ['u','g','r','i','z','y']`

  `vistaBands  = ['Z','Y','J','H','K']`



