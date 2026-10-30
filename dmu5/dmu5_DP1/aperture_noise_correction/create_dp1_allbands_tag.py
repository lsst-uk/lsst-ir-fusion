#!/usr/bin/env python3
"""Combine original ComCam and corrected VIRCAM DP1 catalogues in one TAGGED collection.

Default: read-only inventory. Pass --apply to create the TAGGED collection.
No dataset files are copied or changed.
"""
import argparse
from collections import Counter

from lsst.daf.butler import Butler, CollectionType

REPO = (
    "/rds/project/rds-rPTGgs6He74/Elham/lsst-ir-fusion/"
    "dmu4/dmu4_DP1/dmu4_DP1_ECDFS/data"
)
ORIGINAL = "u/ir-sare1/DRP/videoMultiVisits/20260914T000055Z"
CORRECTED = "u/ir-sare1/DRP/videoMultiVisits_CorrNoise/20261022"
TAG = "u/ir-sare1/DRP/videoMultiVisits_CorrNoise/20261022_allBands"
SKYMAP = "lsst_cells_v1"
TYPES = ("deepCoadd_meas", "deepCoadd_forced_src")
OPTICAL_BANDS = ("u", "g", "r", "i", "z", "y")
VISTA_BANDS = ("Z", "Y", "J", "H", "K")
NIR_EXPECTED = {
    "deepCoadd_meas": {"Z": 42, "Y": 91, "J": 91, "H": 91, "K": 91},
    "deepCoadd_forced_src": {"Z": 42, "Y": 89, "J": 91, "H": 91, "K": 91},
}


def data_key(ref):
    d = ref.dataId
    return (ref.datasetType.name, d["skymap"], d["band"], d["tract"], d["patch"])


def get_refs(registry, dataset_type, collection, allowed_bands):
    all_refs = list(registry.queryDatasets(
        dataset_type, collections=[collection], where=f"skymap='{SKYMAP}'"
    ))
    selected = [r for r in all_refs if r.dataId["band"] in allowed_bands]
    if len({data_key(r) for r in selected}) != len(selected):
        raise RuntimeError(f"Repeated data IDs in {dataset_type} from {collection}")
    return selected


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="Create the TAGGED collection")
    args = parser.parse_args()

    butler = Butler(REPO, writeable=args.apply)
    registry = butler.registry

    selection = {}
    for dtype in TYPES:
        optical = get_refs(registry, dtype, ORIGINAL, OPTICAL_BANDS)
        nir = get_refs(registry, dtype, CORRECTED, VISTA_BANDS)
        opt_counts = Counter(r.dataId["band"] for r in optical)
        nir_counts = Counter(r.dataId["band"] for r in nir)
        print(f"\n{dtype}")
        print("  Original ComCam:", {b: opt_counts[b] for b in OPTICAL_BANDS})
        print("  Corrected VIRCAM:", {b: nir_counts[b] for b in VISTA_BANDS})
        print(f"  Total: {len(optical)} optical + {len(nir)} NIR = {len(optical)+len(nir)}")

        if nir_counts != Counter(NIR_EXPECTED[dtype]):
            raise RuntimeError(f"Unexpected corrected VIRCAM inventory for {dtype}")
        missing_optical = [b for b in OPTICAL_BANDS if opt_counts[b] == 0]
        if missing_optical:
            raise RuntimeError(f"Missing ComCam bands in {dtype}: {missing_optical}")

        selected = optical + nir
        if len({data_key(r) for r in selected}) != len(selected):
            raise RuntimeError(f"Conflicting {dtype} dataset IDs across input RUNs")
        selection[dtype] = selected

    print("\nSelected catalogue datasets:", sum(map(len, selection.values())))
    print("Target TAGGED collection:", TAG)

    # Refuse to modify an existing tag unless it already matches the exact selection.
    existing = TAG in set(registry.queryCollections())
    if existing:
        if registry.getCollectionType(TAG) != CollectionType.TAGGED:
            raise RuntimeError(f"Existing collection is not TAGGED: {TAG}")
        for dtype, expected in selection.items():
            actual = list(registry.queryDatasets(dtype, collections=[TAG]))
            if {r.id for r in actual} != {r.id for r in expected}:
                raise RuntimeError(f"Existing TAGGED collection differs for {dtype}; no changes made")
        print("TAG already exists and exactly matches the selected catalogue datasets.")
        return

    if not args.apply:
        print("\nPLAN ONLY: no collections registered and no datasets associated.")
        print("If counts and bands are correct, rerun with --apply.")
        return

    registry.registerCollection(
        TAG, CollectionType.TAGGED,
        doc=("DP1 optical ComCam measured/forced catalogues (original) and "
             "VIRCAM measured/forced catalogues with seven circular-aperture "
             "correlated-noise uncertainty fields corrected; 2026-10-22.")
    )

    with registry.transaction():
        for dtype, refs in selection.items():
            registry.associate(TAG, refs)

    # Verify the exact dataset IDs, not just totals.
    for dtype, expected in selection.items():
        actual = list(registry.queryDatasets(dtype, collections=[TAG]))
        if {r.id for r in actual} != {r.id for r in expected}:
            raise RuntimeError(f"Verification failed for {dtype}")
        print(f"VERIFIED {dtype}: {len(actual)} catalogue datasets")
    print("\nSUCCESS: unified TAGGED collection created:", TAG)
    print("No dataset files were copied or modified.")


if __name__ == "__main__":
    main()
