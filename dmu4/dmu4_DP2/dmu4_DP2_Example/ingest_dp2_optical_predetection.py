#!/usr/bin/env python3
"""
Ingest reconstructed Rubin DP2 optical predetection CellCoadds
into a Gen3 Butler repository.

Supports:
    - One tract and patch
    - All patches in a tract
    - All available tracts and patches

Expected input filename:
    deep_coadd_cell_predetection_{tract}_{patch}_{band}.fits

The CellCoadds must already have been reconstructed in dmu0.
"""

import argparse
import re
from pathlib import Path

from lsst.cell_coadds import MultipleCellCoadd
from lsst.daf.butler import Butler


DATASET_TYPE = "deep_coadd_cell_predetection"

FILENAME_PATTERN = re.compile(
    r"^deep_coadd_cell_predetection_(\d+)_(\d+)_([A-Za-z0-9]+)\.fits$"
)


def find_input_files(input_dir, tract=None, patch=None, bands=None):
    """Discover reconstructed optical CellCoadds."""

    files = {}

    for path in sorted(input_dir.rglob("*.fits")):

        match = FILENAME_PATTERN.match(path.name)

        if match is None:
            continue

        file_tract = int(match.group(1))
        file_patch = int(match.group(2))
        file_band = match.group(3)

        if tract is not None and file_tract != tract:
            continue

        if patch is not None and file_patch != patch:
            continue

        if bands is not None and file_band not in bands:
            continue

        key = (file_tract, file_patch, file_band)

        if key in files:
            raise ValueError(
                f"Duplicate input for {key}: "
                f"{files[key]} and {path}"
            )

        files[key] = path

    return files


def main():

    parser = argparse.ArgumentParser(
        description="Ingest reconstructed DP2 optical CellCoadds."
    )

    parser.add_argument("--repo", default="data", help="Butler repository")
    parser.add_argument("--input-dir", type=Path, required=True)
    parser.add_argument(
        "--run",
        default="LSSTCam/elais/optical_predetections",
        help="Output RUN collection",
    )
    parser.add_argument(
        "--skymap",
        default="lsst_cells_v2",
    )
    parser.add_argument(
        "--tract",
        type=int,
        default=None,
        help="Optional tract selection",
    )
    parser.add_argument(
        "--patch",
        type=int,
        default=None,
        help="Optional patch selection",
    )
    parser.add_argument(
        "--bands",
        nargs="+",
        default=["u", "g", "r", "i", "z", "y"],
    )
    parser.add_argument(
        "--skip-existing",
        action="store_true",
        help="Skip datasets already registered in the output RUN",
    )

    args = parser.parse_args()

    input_dir = args.input_dir.resolve()

    if not input_dir.is_dir():
        raise FileNotFoundError(input_dir)

    # Discover files before opening the Butler for writing.
    files = find_input_files(
        input_dir,
        tract=args.tract,
        patch=args.patch,
        bands=args.bands,
    )

    if not files:
        raise RuntimeError("No matching optical CellCoadd files found.")

    # Require all requested bands for an explicitly selected patch.
    if args.tract is not None and args.patch is not None:
        found_bands = {band for _, _, band in files}
        missing = set(args.bands) - found_bands

        if missing:
            raise FileNotFoundError(
                f"Missing bands for tract={args.tract}, "
                f"patch={args.patch}: {sorted(missing)}"
            )

    butler = Butler.from_config(args.repo, writeable=True)

    # Load the registered SkyMap for identifier verification.
    skymap = butler.get(
        "skyMap",
        skymap=args.skymap,
        collections=["skymaps"],
    )

    butler.registry.registerRun(args.run)

    print(f"Butler repo : {args.repo}")
    print(f"Collection  : {args.run}")
    print(f"SkyMap      : {args.skymap}")
    print(f"Input files : {len(files)}")

    ingested = 0
    skipped = 0

    for (tract, patch, band), filename in sorted(files.items()):

        data_id = {
            "skymap": args.skymap,
            "tract": tract,
            "patch": patch,
            "band": band,
        }

        existing = butler.registry.findDataset(
            DATASET_TYPE,
            dataId=data_id,
            collections=[args.run],
        )

        if existing is not None:
            if args.skip_existing:
                print(f"[SKIP] {tract}/{patch}/{band}: already ingested")
                skipped += 1
                continue

            raise RuntimeError(
                f"Dataset already exists in {args.run}: {data_id}. "
                "Use --skip-existing to continue."
            )

        print(f"\nReading: {filename}")

        coadd = MultipleCellCoadd.readFits(str(filename))
        identifiers = coadd.common.identifiers

        # Verify identifiers embedded in the FITS file.
        expected_patch = skymap[tract][patch].getIndex()

        if (
            identifiers.skymap != args.skymap
            or identifiers.tract != tract
            or identifiers.patch != expected_patch
            or identifiers.band != band
        ):
            raise ValueError(
                f"CellCoadd identifier mismatch for {filename}\n"
                f"Found: {identifiers}\n"
                f"Expected: {data_id}, patch index={expected_patch}"
            )

        ref = butler.put(
            coadd,
            DATASET_TYPE,
            dataId=data_id,
            run=args.run,
        )

        ingested += 1

        print(f"[OK] tract={tract} patch={patch} band={band}")
        print(f"     cells={len(coadd.cells)}")
        print(f"     dataset={ref.id}")

    print("\nIngestion completed")
    print(f"Ingested : {ingested}")
    print(f"Skipped  : {skipped}")
    print(f"Total    : {len(files)}")


if __name__ == "__main__":
    main()
