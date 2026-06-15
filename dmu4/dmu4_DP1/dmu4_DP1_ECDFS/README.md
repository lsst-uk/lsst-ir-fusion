## Ingesting VISTA VIRCAM Raw & Confidence Maps into LSST Butler

Typical workflow assumes:

```shell
repo                        # Butler repository
cdfs_images.txt             # list of *_st.fit files (science images)
make_conf_ecsv.py           # helper script for confidence maps
cdfs_index_conf.ecsv        # generated index of confidence maps
cdfs_conf_failed.txt        # log of missing/duplicate files
```

### 1. **Raw image ingestion**

   Historically, raw ingestion required generating a JSON index with all
   metadata and using a loop for.
   
   Each entry in the JSON described one raw FITS file and its metadata
  `exposure`, `detector`, `band`, `physical_filter`, etc.
   
   **Limitations of JSON method:**
   
   * All metadata had to be precomputed and serialised to JSON manually.
   * Hard to maintain if the header-to-butler mapping changed.
   * Very slow ingestion (more than 15 hours for 5000 images)
   
   **New method (header translators)**
   
   Now we rely on `astro_metadata_translator` and the custom `VircamTranslator` 
   in `lsstuk.obs.vista.translators.vircam`.
   
   The translator extracts metadata directly from FITS headers.
   Butler opens each file, applies the `VircamTranslator`, and extracts:
   
   * `exposure` → `ESO DET EXP NO`
   * `detector` → `ESO DET CHIP NO`
   * `band` / `physical_filter` → `FILTER` or `FLATCOR`
   * `day_obs`, `start_time`, `end_time` → `DATE-OBS`
   
   **Command:**
   
```shell
   butler ingest-raws $repo \
       $(cat ../../../dmu0/dmu0_VISTA/dmu0_VIDEO_CDFS/cdfs_images.txt) \
       -t copy --output-run VIRCAM/raw/video_cdfs
```

   **Advantages:**

   * Always consistent with FITS headers.
   * No need to maintain external JSON.
   * Can ingest thousands of images in one command.
   * Translator handles instrument-specific quirks (like VIRCAM multiextension
   FITS).
   * Faster and more robust (around 1 hour for 5000 images).


### 2. **Confidence map ingestion**

   Confidence maps (`*_st_conf.fit`) are not raw images, so Butler doesn’t know
   about them by default.
   To ingest them, we need two extra steps:
   
   **Step 1 — Register dataset type**
  
```shell
butler register-dataset-type $REPO confidence ExposureF \
       instrument band physical_filter exposure detector day_obs
```
   
   * `confidence` → dataset type name.
   * `ExposureF` → storage class (floating-point image).
   * `Dimensions` (`instrument`, `band`, `physical_filter`, `exposure`,
   `detector`, `day_obs`) describe uniqueness.


   **Step 2 — Generate ECSV index**
   
   We generate an ECSV file listing all confidence maps and their metadata
   (columns must match the dataset type).

   The Python code `make_conf_ecsv.py` (in `dmu0_VIDEO_CDFS`) generates an ecsv
   file:
   
   1. Reads `cdfs_images.txt` (science images).
   2. Finds matching confidence maps (`*_st_conf.fit`).
   3. Extracts metadata with `ObservationInfo` + `VircamTranslator`.
   4. Writes one row per detector (1–16).
   5. Detects duplicate (`exposure`, `detector`):
   6. Outputs:
  * `cdfs_index_conf.ecsv` → ready for ingestion.
  * `cdfs_conf_failed.txt` → missing/failed/conflicting files.
     
  **Problem: Duplicate handling**
   
   Sometimes two different FITS files claim the same `ESO DET EXP NO`.
   Butler does not allow ingesting two datasets with the same (`exposure`,
   `detector`).

   Solution in `make_conf_ecsv.py`:

   * If only a small number of exposures (≤10) and rows
   (≤160, i.e. 10 exposures × 16 detectors) are duplicated:

    * Keep the first file.
    * Remove others and log them in `dp1_conf_failed.txt`.

   * If too many duplicates are found, script aborts to avoid silent data loss.
   
   This ensures ingest will succeed without `ConflictingDefinitionError`.

  **Step 3 — Ingest confidence maps**

```shell
butler ingest-files --formatter=lsstuk.obs.vista.VircamRawFormatter \
       $repo confidence confidence/video_cdfs \
       ../../../dmu0/dmu0_VISTA/dmu0_VIDEO_CDFS/cdfs_index_conf.ecsv -t copy
```

   * `confidence` → dataset type.
   * `confidence/video_cdfs` → collection name.
   * `cdfs_index_conf.ecsv` → index file from script.
   * `-t copy` → copy into repo storage.
