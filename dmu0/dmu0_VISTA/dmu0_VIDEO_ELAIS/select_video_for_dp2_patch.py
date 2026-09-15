#!/usr/bin/env python3

"""
Select VIDEO pawprints needed for one Rubin/LSST DP2 patch.

This script is intended to run on CSD3, where the original VIDEO
_st.fit and _st_conf.fit files are available.

Inputs
------
1. A small patch-geometry CSV exported from the Rubin Science Platform.
2. elais_video_detector_points.csv, containing one row per VIRCAM detector.

Output
------
A staging directory containing:
  - symbolic links to the complete selected _st.fit files;
  - symbolic links to their complete _st_conf.fit files;
  - selected_detector_rows.csv: detector-level overlap information;
  - selected_images.csv: one row per selected pawprint with detector list.

The FITS files themselves are NOT copied on CSD3. Use rsync -L from the
desktop to follow the symbolic links and transfer the real files.
"""

import argparse
from pathlib import Path

import numpy as np
import pandas as pd


def parse_args():
    parser = argparse.ArgumentParser(
        description="Stage VIDEO files overlapping one DP2 patch."
    )
    parser.add_argument(
        "--patch",
        required=True,
        type=Path,
        help="Patch geometry CSV exported from the RSP notebook.",
    )
    parser.add_argument(
        "--detectors",
        required=True,
        type=Path,
        help="elais_video_detector_points.csv",
    )
    parser.add_argument(
        "--output",
        required=True,
        type=Path,
        help="Output staging directory.",
    )
    parser.add_argument(
        "--pad-arcsec",
        type=float,
        default=10.0,
        help="Padding added around the DP2 patch before overlap selection.",
    )
    return parser.parse_args()


def main():
    args = parse_args()

    # ------------------------------------------------------------
    # Read the DP2 patch geometry exported from RSP
    # ------------------------------------------------------------
    patch = pd.read_csv(args.patch)

    required_patch_columns = {
        "tract",
        "patch",
        "vertex_order",
        "ra_deg",
        "dec_deg",
    }

    missing = required_patch_columns - set(patch.columns)
    if missing:
        raise ValueError(
            f"Patch CSV is missing required columns: {sorted(missing)}"
        )

    tract = int(patch["tract"].iloc[0])
    patch_id = int(patch["patch"].iloc[0])

    vertices = patch.sort_values("vertex_order")[["ra_deg", "dec_deg"]].to_numpy()

    pad_deg = args.pad_arcsec / 3600.0

    patch_ra_min = vertices[:, 0].min() - pad_deg
    patch_ra_max = vertices[:, 0].max() + pad_deg
    patch_dec_min = vertices[:, 1].min() - pad_deg
    patch_dec_max = vertices[:, 1].max() + pad_deg

    print()
    print("DP2 patch")
    print("---------")
    print(f"tract           : {tract}")
    print(f"patch           : {patch_id}")
    print(f"RA range        : {patch_ra_min:.7f} .. {patch_ra_max:.7f} deg")
    print(f"Dec range       : {patch_dec_min:.7f} .. {patch_dec_max:.7f} deg")
    print(f"selection pad   : {args.pad_arcsec:.1f} arcsec")

    # ------------------------------------------------------------
    # Read the precomputed VIDEO detector footprints
    # ------------------------------------------------------------
    det = pd.read_csv(args.detectors)

    required_detector_columns = {
        "fits_path",
        "filename",
        "detector",
        "ra_cen",
        "dec_cen",
        "ra_min_det",
        "ra_max_det",
        "dec_min_det",
        "dec_max_det",
    }

    missing = required_detector_columns - set(det.columns)
    if missing:
        raise ValueError(
            f"Detector table is missing required columns: {sorted(missing)}"
        )

    # Conservative overlap test:
    # select a detector whenever its RA/Dec bounding box intersects
    # the padded bounding box of the DP2 patch.
    overlap = det[
        (det["ra_max_det"] >= patch_ra_min)
        & (det["ra_min_det"] <= patch_ra_max)
        & (det["dec_max_det"] >= patch_dec_min)
        & (det["dec_min_det"] <= patch_dec_max)
    ].copy()

    if overlap.empty:
        raise RuntimeError("No VIDEO detectors overlap this DP2 patch.")

    overlap["tract"] = tract
    overlap["patch"] = patch_id

    # ------------------------------------------------------------
    # Group detector rows by full VIDEO pawprint
    # ------------------------------------------------------------
    selected = (
        overlap.groupby(["fits_path", "filename"], as_index=False)
        .agg(
            n_candidate_detectors=("detector", "nunique"),
            candidate_detectors=(
                "detector",
                lambda x: ",".join(str(v) for v in sorted(set(map(int, x)))),
            ),
        )
        .sort_values("fits_path")
        .reset_index(drop=True)
    )

    selected["tract"] = tract
    selected["patch"] = patch_id

    selected["st_path"] = selected["fits_path"].map(Path)
    selected["conf_path"] = selected["st_path"].map(
        lambda p: p.with_name(p.name.replace("_st.fit", "_st_conf.fit"))
    )

    selected["st_exists"] = selected["st_path"].map(Path.exists)
    selected["conf_exists"] = selected["conf_path"].map(Path.exists)

    print()
    print("VIDEO selection")
    print("---------------")
    print(f"candidate detector rows : {len(overlap)}")
    print(f"unique _st.fit files    : {len(selected)}")

    detector_counts = (
        selected["n_candidate_detectors"]
        .value_counts()
        .sort_index()
    )

    print()
    print("Number of candidate detectors per pawprint:")
    for n_det, n_images in detector_counts.items():
        print(f"  {int(n_det):2d} detector(s): {int(n_images)} image(s)")

    # ------------------------------------------------------------
    # Require the complete _st.fit and _st_conf.fit pair
    # ------------------------------------------------------------
    bad = selected[
        (~selected["st_exists"]) | (~selected["conf_exists"])
    ].copy()

    args.output.mkdir(parents=True, exist_ok=True)

    if not bad.empty:
        missing_path = args.output / "missing_file_pairs.csv"
        bad.to_csv(missing_path, index=False)

        print()
        print(f"Missing pairs written to: {missing_path}")
        print(
            f"missing _st.fit      : {(~selected['st_exists']).sum()}"
        )
        print(
            f"missing _st_conf.fit : {(~selected['conf_exists']).sum()}"
        )

        raise RuntimeError(
            "Some selected pawprints do not have both _st.fit and "
            "_st_conf.fit. No staging links were created."
        )

    # ------------------------------------------------------------
    # Save manifests before making links
    # ------------------------------------------------------------
    detector_manifest = args.output / "selected_detector_rows.csv"
    image_manifest = args.output / "selected_images.csv"

    overlap.sort_values(["fits_path", "detector"]).to_csv(
        detector_manifest,
        index=False,
    )

    selected_for_csv = selected.copy()
    selected_for_csv["st_path"] = selected_for_csv["st_path"].astype(str)
    selected_for_csv["conf_path"] = selected_for_csv["conf_path"].astype(str)

    selected_for_csv.to_csv(
        image_manifest,
        index=False,
    )

    # ------------------------------------------------------------
    # Make one flat staging directory of symlinks.
    #
    # VIDEO filenames include the observing date, so they should be
    # unique. We nevertheless check for collisions explicitly.
    # ------------------------------------------------------------
    link_dir = args.output / "fits"
    link_dir.mkdir(parents=True, exist_ok=True)

    expected_names = []
    for row in selected.itertuples(index=False):
        expected_names.extend(
            [Path(row.st_path).name, Path(row.conf_path).name]
        )

    if len(expected_names) != len(set(expected_names)):
        raise RuntimeError(
            "Duplicate FITS basenames were found; refusing to make a "
            "flat staging directory."
        )

    total_bytes = 0

    for row in selected.itertuples(index=False):
        for source in (Path(row.st_path), Path(row.conf_path)):
            target = link_dir / source.name

            if target.exists() or target.is_symlink():
                target.unlink()

            target.symlink_to(source)
            total_bytes += source.stat().st_size

    # ------------------------------------------------------------
    # Final summary
    # ------------------------------------------------------------
    print()
    print("Staging complete")
    print("----------------")
    print(f"directory              : {args.output}")
    print(f"FITS symlink directory : {link_dir}")
    print(f"_st/_st_conf pairs     : {len(selected)}")
    print(f"total FITS links       : {2 * len(selected)}")
    print(f"real transfer size     : {total_bytes / 1024**3:.2f} GiB")
    print(f"detector manifest      : {detector_manifest}")
    print(f"image manifest         : {image_manifest}")

    print()
    print("The FITS files were not duplicated on CSD3.")
    print("Use rsync -L from the desktop so the symlinks are followed.")


if __name__ == "__main__":
    main()
