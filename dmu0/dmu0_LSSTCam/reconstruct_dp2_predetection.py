#!/usr/bin/env python3
"""
Reconstruct one optical DP2 predetection CellCoadd from a public CellCoadd.

The original lsst_cells_v2 SkyMap identifier is preserved.
The companion shell script processes all available tracts, patches and bands.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from lsst.images.cells import CellCoadd
from lsst.cell_coadds import MultipleCellCoadd


EXPECTED_SKYMAP = "lsst_cells_v2"
MASK_PLANES_TO_CLEAR = ("DETECTED", "DETECTED_NEGATIVE")


def count_mask_pixels(coadd: MultipleCellCoadd, plane: str) -> int:
    total = 0

    for index in coadd.cells:
        mask = coadd.cells[index].outer.mask

        if plane not in mask.getMaskPlaneDict():
            continue

        bit = 1 << mask.getMaskPlane(plane)
        total += int(np.count_nonzero(mask.array & bit))

    return total


def clear_detection_mask_planes(coadd: MultipleCellCoadd) -> None:
    for index in coadd.cells:
        mask = coadd.cells[index].outer.mask
        plane_dict = mask.getMaskPlaneDict()

        for plane in MASK_PLANES_TO_CLEAR:
            if plane in plane_dict:
                mask.clearMaskPlane(mask.getMaskPlane(plane))


def reconstruct_predetection(
    input_file: Path,
    output_file: Path,
    overwrite: bool = False,
) -> None:

    if not input_file.is_file():
        raise FileNotFoundError(input_file)

    if output_file.exists() and not overwrite:
        raise FileExistsError(
            f"Output already exists: {output_file}. "
            "Use --overwrite to regenerate it."
        )

    print(f"Reading public CellCoadd: {input_file}")

    coadd = CellCoadd.read(str(input_file))

    print(f"band        : {coadd.band}")
    print(f"backgrounds : {list(coadd.backgrounds)}")
    print(f"bbox        : {coadd.bbox}")

    # Restore background subtracted for the public object product.
    coadd.apply_background(None)

    # Convert to the legacy format required by CellCoadd-mode detection.
    predetection = coadd.to_legacy_cell_coadd(copy=True)
    identifiers = predetection.common.identifiers

    # Verify the original Rubin DP2 SkyMap identifier.
    if identifiers.skymap != EXPECTED_SKYMAP:
        raise ValueError(
            f"Unexpected embedded SkyMap {identifiers.skymap!r} "
            f"in {input_file}; expected {EXPECTED_SKYMAP!r}."
        )

    print(f"cells       : {len(predetection.cells)}")
    print(f"identifiers : {identifiers}")

    print("Mask pixels before clearing:")
    for plane in MASK_PLANES_TO_CLEAR:
        print(
            f"  {plane:18s}: "
            f"{count_mask_pixels(predetection, plane)}"
        )

    # Clear only post-detection flags.
    clear_detection_mask_planes(predetection)

    print("Mask pixels after clearing:")
    for plane in MASK_PLANES_TO_CLEAR:
        print(
            f"  {plane:18s}: "
            f"{count_mask_pixels(predetection, plane)}"
        )

    # Preserve the original SkyMap identifiers.
    output_file.parent.mkdir(parents=True, exist_ok=True)
    predetection.writeFits(str(output_file))

    # Read back and verify.
    check = MultipleCellCoadd.readFits(str(output_file))

    print("Read-back check:")
    print(f"  identifiers : {check.common.identifiers}")
    print(f"  cells       : {len(check.cells)}")

    if check.common.identifiers != identifiers:
        raise RuntimeError("CellCoadd identifiers changed during writing.")

    if len(check.cells) != len(predetection.cells):
        raise RuntimeError("Cell count changed during writing.")

    for plane in MASK_PLANES_TO_CLEAR:
        count = count_mask_pixels(check, plane)
        print(f"  {plane:18s}: {count}")

        if count != 0:
            raise RuntimeError(
                f"{plane} mask was not completely cleared."
            )

    print(f"Written: {output_file}")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)

    parser.add_argument(
        "input",
        type=Path,
        help="Public deep_coadd FITS file",
    )

    parser.add_argument(
        "output",
        type=Path,
        help="Output predetection FITS file",
    )

    parser.add_argument(
        "--overwrite",
        action="store_true",
        help="Replace an existing output",
    )

    args = parser.parse_args()

    reconstruct_predetection(
        input_file=args.input,
        output_file=args.output,
        overwrite=args.overwrite,
    )


if __name__ == "__main__":
    main()
