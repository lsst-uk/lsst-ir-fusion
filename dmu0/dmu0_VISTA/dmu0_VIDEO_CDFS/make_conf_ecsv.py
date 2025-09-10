#!/usr/bin/env python3
"""
make_conf_ecsv.py
-----------------
Generate an ECSV index for VIRCAM confidence maps.

Reads `cdfs_images.txt` (list of *_st.fit files),
derives exposure metadata from FITS headers via astro_metadata_translator,
and writes an ECSV file for confidence maps.

Output:
  - cdfs_index_conf.ecsv (filename, instrument, band,
                         physical_filter, exposure, detector, day_obs)
  - cdfs_conf_failed.txt (files that failed metadata extraction
                         or were removed as duplicates)
"""

import os
from pathlib import Path
from astropy.table import Table
from astropy.io import fits
from astro_metadata_translator import ObservationInfo
from astropy.time import Time
import lsstuk.obs.vista.translators.vircam as _vir  # ensure VIRCAM translator registered
from collections import defaultdict

# Input/output files
fits_list = Path("cdfs_images.txt")
conf_ecsv = Path("cdfs_index_conf.ecsv")
failed_txt = Path("cdfs_conf_failed.txt")

def get_obs_info(filename):
    """Extract ObservationInfo from FITS (merge HDU0 + HDU1 headers)."""
    with fits.open(filename, memmap=False) as hdul:
        hdr = hdul[0].header.copy()
        if len(hdul) > 1:
            try:
                hdr.update(hdul[1].header)
            except Exception:
                pass
    return ObservationInfo(hdr, filename=filename)

conf_rows = []
failed = []

# Read file list
with open(fits_list, "r") as f:
    files = [line.strip() for line in f if line.strip()]

print(f"Found {len(files)} entries in {fits_list}")

for i, fn in enumerate(files, 1):
    if not os.path.exists(fn):
        failed.append(f"# MISSING: {fn}")
        print(f"[{i}/{len(files)}] MISSING: {fn}")
        continue

    try:
        oi = get_obs_info(fn)
    except Exception as e:
        failed.append(f"{fn}    # fail: {e}")
        print(f"[{i}/{len(files)}] FAILED metadata: {fn} -> {e}")
        continue

    # Metadata
    exposure = int(oi.exposure_id) if oi.exposure_id is not None else None
    instrument = str(oi.instrument) if oi.instrument is not None else "VIRCAM"
    physical_filter = str(oi.physical_filter) if oi.physical_filter is not None else "UNKNOWN"
    band = physical_filter.split("-")[-1] if "-" in physical_filter else physical_filter
    day_obs = int(Time(oi.datetime_begin).strftime("%Y%m%d")) if oi.datetime_begin else None

    # Confidence map filename
    conf_candidate = fn.replace("_st.fit", "_st_conf.fit")
    if not os.path.exists(conf_candidate):
        conf_candidate = fn.replace("_st.fit", "_conf.fit")

    if not os.path.exists(conf_candidate):
        failed.append(f"# NO_CONF: {fn}")
        print(f"[{i}/{len(files)}] No conf file for {fn}")
        continue

    # One row per detector (1–16)
    for det in range(1, 17):
        conf_rows.append(
            (conf_candidate, instrument, band, physical_filter, exposure, det, day_obs)
        )

# Build dictionary seen[(exposure, detector)] -> list(rows)
seen = defaultdict(list)
for row in conf_rows:
    key = (row[4], row[5])   # row: (filename, instrument, band, physical_filter, exposure, detector, day_obs)
    seen[key].append(row)


# Check for duplicate exposures
duplicate_pairs = {k: v for k, v in seen.items() if len(v) > 1}

# counts for decision making
duplicate_pairs_count = sum(len(v) - 1 for v in duplicate_pairs.values())  # number of rows to remove
duplicate_exposures = set(k[0] for k in duplicate_pairs.keys())  # unique exposure IDs affected
dup_exposure_count = len(duplicate_exposures)

# thresholds (tune if you want)
MAX_DUP_EXPOSURES = 10       # number of distinct exposures allowed to auto-resolve
MAX_PAIR_REMOVALS = 160      # number of (exposure,detector) rows to remove allowed to auto-resolve

if duplicate_pairs:
    print(f"⚠️ Found {len(duplicate_pairs)} duplicate (exposure,detector) keys.")
    print(f"   → total extra rows to remove: {duplicate_pairs_count}")
    print(f"   → unique exposures affected: {dup_exposure_count}: {sorted(list(duplicate_exposures))[:20]}")

    if dup_exposure_count <= MAX_DUP_EXPOSURES and duplicate_pairs_count <= MAX_PAIR_REMOVALS:
        print("Auto-resolving duplicates (keeping first occurrence per exposure+detector).")
        new_rows = []
        removed_list = []
        for key, rows in seen.items():
            # keep the first row and drop the rest
            new_rows.append(rows[0])
            for r in rows[1:]:
                removed_list.append(r)
                failed.append(f"# DUPLICATE REMOVED: {r[0]} exp={r[4]} det={r[5]} day_obs={r[6]}")
                print(f"  -> removed {r[0]} (exp={r[4]} det={r[5]})")
        conf_rows = new_rows
        print(f"Auto-resolve done: kept {len(conf_rows)} rows, removed {len(removed_list)} rows.")
    else:
        # Too many duplicates; abort and write diagnostics
        print("❌ Too many duplicates to auto-resolve. Aborting and writing failure report.")
        with open(failed_txt, "w") as ff:
            ff.write("\n".join(failed))
            ff.write("\n\n# Duplicate summary:\n")
            ff.write(f"duplicate_pairs_count={duplicate_pairs_count}\n")
            ff.write(f"dup_exposure_count={dup_exposure_count}\n")
            ff.write("affected_exposures:\n")
            for e in sorted(duplicate_exposures):
                ff.write(f"{e}\n")
        raise SystemExit(1)
else:
    print("No duplicates found.")


# Write ECSV
colnames = ["filename", "instrument", "band", "physical_filter", "exposure", "detector", "day_obs"]

if conf_rows:
    t_conf = Table(rows=conf_rows, names=colnames)
    t_conf.write(conf_ecsv, format="ascii.ecsv", overwrite=True)
    print(f"✅ Wrote confidence ECSV: {conf_ecsv} (rows: {len(t_conf)})")
else:
    print("No confidence files found; conf ECSV not written.")

if failed:
    with open(failed_txt, "w") as ff:
        ff.write("\n".join(failed))
    print(f"⚠️ Wrote failures: {failed_txt} (count: {len(failed)})")
