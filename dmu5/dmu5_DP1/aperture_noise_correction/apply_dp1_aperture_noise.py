#!/usr/bin/env python3
"""Apply DP1 VISTA aperture-noise factors to measured and forced SourceCatalogs.

Inputs (explicit September 2026 RUNs):
  deepCoadd_meas         from videoMultiVisits/20260914T000055Z
  deepCoadd_forced_src   from videoMultiVisits/20260914T000055Z

Output products (SAME dataset types in a DIFFERENT RUN):
  deepCoadd_meas
  deepCoadd_forced_src

Only the seven base_CircularApertureFlux_*_instFluxErr column values change.
A write is immediately followed by a complete scalar-column read-back audit.

Modes:
  plan: no registry/data changes; inventory and schema preflight.
  test: write one catalogue per selected input type to a TEST RUN.
  full: write every selected catalogue to a distinct PRODUCTION RUN.
Re-running a mode verifies and skips already correct output datasets.
"""

import argparse
import csv
import gc
import hashlib
import json
import logging
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

import numpy as np
from lsst.daf.butler import Butler

LOG = logging.getLogger("apNoise")

DEFAULT_REPO = (
    "/home/ir-sare1/rds/rds-iris-ip005/Elham/lsst-ir-fusion/"
    "dmu4/dmu4_DP1/dmu4_DP1_ECDFS/data"
)
SKYMAP = "lsst_cells_v1"
BANDS = ("Z", "Y", "J", "H", "K")
RADII = (3.0, 4.5, 6.0, 9.0, 12.0, 17.0, 25.0)

INPUTS = {
    "measured": (
        "deepCoadd_meas",
        "u/ir-sare1/DRP/videoMultiVisits/20260914T000055Z",
        "deepCoadd_meas",
    ),
    "forced": (
        "deepCoadd_forced_src",
        "u/ir-sare1/DRP/videoMultiVisits/20260914T000055Z",
        "deepCoadd_forced_src",
    ),
}


def field_for_radius(radius):
    return f"base_CircularApertureFlux_{radius:.1f}".replace(".", "_") + "_instFluxErr"


FIELDS = {radius: field_for_radius(radius) for radius in RADII}
ALL_CORRECTED_FIELDS = frozenset(FIELDS.values())


def read_calibration(path):
    """Reject duplicate, missing, NaN, and implausible factors."""
    raw = Path(path).read_bytes()
    rows = list(csv.DictReader(raw.decode("utf-8-sig").splitlines()))
    values = {}
    for row in rows:
        band = row["band"].strip()
        radius = float(row["radius"])
        value = float(row["C_median"])
        key = (band, radius)
        if key in values:
            raise ValueError(f"Duplicate calibration key: {key}")
        if band not in BANDS or radius not in RADII:
            raise ValueError(f"Unexpected band/radius: {key}")
        if not np.isfinite(value) or value <= 0:
            raise ValueError(f"Invalid correction factor {key}: {value}")
        if int(row["N_patches"]) < 10:
            raise ValueError(f"Too few calibration patches: {key}")
        values[key] = value
    expected = {(b, r) for b in BANDS for r in RADII}
    if set(values) != expected or len(rows) != 35:
        raise ValueError(f"Calibration must contain exactly 35 entries; missing={expected-set(values)}")
    return values, hashlib.sha256(raw).hexdigest()


def data_id(ref):
    return {
        "skymap": str(ref.dataId["skymap"]),
        "tract": int(ref.dataId["tract"]),
        "patch": int(ref.dataId["patch"]),
        "band": str(ref.dataId["band"]),
    }


def check_schema(cat, context):
    names = sorted(cat.schema.getNames())
    if len(names) != len(set(names)):
        raise AssertionError(f"{context}: duplicate names")
    missing = ALL_CORRECTED_FIELDS - set(names)
    if missing:
        raise AssertionError(f"{context}: missing required fields: {sorted(missing)}")
    for name in ALL_CORRECTED_FIELDS:
        if np.asarray(cat[name]).dtype.kind not in "f":
            raise TypeError(f"{context}: non-floating-point error field {name}")


def check_metadata(a, b, context, *, roundtrip=False):
    """Preserve all non-Butler metadata; recognize Butler's new output identity.

    In memory, no metadata changes are permitted.  During Butler.put/get,
    the formatter assigns a NEW dataset ID/type and does not copy the old
    LSST BUTLER INPUT provenance cards.  Those cards refer to the ORIGINAL
    processing run and cannot honestly describe the new derived dataset.
    Original-input IDs and the calibration hash are recorded in the JSONL
    audit log; all other metadata must still be exactly equal.
    """
    ma = a.getTable().getMetadata()
    mb = b.getTable().getMetadata()
    if not roundtrip:
        if str(ma) != str(mb):
            raise AssertionError(f"{context}: IN-MEMORY table metadata changed")
        return

    original = {} if ma is None else ma.toDict()
    written = {} if mb is None else mb.toDict()

    def preserved(metadata):
        return {
            key: value for key, value in metadata.items()
            if not str(key).startswith("LSST BUTLER ")
        }

    try:
        # This checks both key presence and exact values, including NaNs.
        np.testing.assert_equal(preserved(original), preserved(written))
    except AssertionError as exc:
        raise AssertionError(
            f"{context}: NON-BUTLER table metadata changed"
        ) from exc


def check_footprints(a, b, context, samples=25):
    """Check selected footprints, including their full pixel spans.

    Every numerical/flag/catalogue field is always checked, not sampled.
    Deep-copy construction preserves footprints; this also checks persistence.
    """
    if len(a) == 0:
        return
    for i in np.unique(np.linspace(0, len(a)-1, min(samples, len(a)), dtype=int)):
        old = a[int(i)].getFootprint()
        new = b[int(i)].getFootprint()
        if old is None or new is None:
            if (old is None) != (new is None):
                raise AssertionError(f"{context}: footprint presence differs at row {i}")
            continue
        if old.getArea() != new.getArea() or old.getBBox() != new.getBBox():
            raise AssertionError(f"{context}: footprint geometry changed at row {i}")
        if len(old.getPeaks()) != len(new.getPeaks()):
            raise AssertionError(f"{context}: footprint peaks changed at row {i}")
        np.testing.assert_array_equal(
            old.getSpans().asArray(), new.getSpans().asArray(),
            err_msg=f"{context}: footprint spans differ at row {i}",
        )
        for po, pn in zip(old.getPeaks(), new.getPeaks()):
            if (po.getIx(), po.getIy()) != (pn.getIx(), pn.getIy()):
                raise AssertionError(f"{context}: footprint peak position changed at row {i}")


def assert_same_structure(a, b, context, *, roundtrip=False):
    if len(a) != len(b):
        raise AssertionError(f"{context}: row count differs")
    if a.schema.getOrderedNames() != b.schema.getOrderedNames():
        raise AssertionError(f"{context}: schema field names/order differ")

    original_schema = a.schema
    flags = original_schema.compare(b.schema, original_schema.IDENTICAL)
    required = original_schema.IDENTICAL
    if roundtrip:
        # LSST SourceCatalog FITS I/O can double FITS-escaped apostrophes
        # or truncate long free-text documentation.  Only this *descriptive*
        # part of the schema is exempted from the persisted comparison.
        required &= ~original_schema.EQUAL_DOCS
    if (flags & required) != required:
        missing = [
            label for label in (
                "EQUAL_KEYS", "EQUAL_NAMES", "EQUAL_UNITS",
                "EQUAL_ALIASES", "EQUAL_DOCS"
            )
            if (required & getattr(original_schema, label))
            and not (flags & getattr(original_schema, label))
        ]
        raise AssertionError(
            f"{context}: schema differs in {missing}"
        )
    if roundtrip and not (flags & original_schema.EQUAL_DOCS):
        LOG.debug("%s: field documentation changed on FITS read/write", context)
    check_metadata(a, b, context, roundtrip=roundtrip)
    check_footprints(a, b, context)


def expected_error(original_values, C):
    """Keep zeros, negatives, NaNs, and infinities unchanged, like the K-band test."""
    expected = np.array(original_values, copy=True)
    valid = np.isfinite(expected) & (expected > 0)
    expected[valid] *= C  # rounds naturally to original field's dtype
    if not np.all(np.isfinite(expected[valid])):
        raise ArithmeticError("Correction overflowed a finite positive uncertainty")
    return expected, int(np.count_nonzero(valid))


def get_field_values(cat, name):
    """Read both vectorized and non-vectorized LSST SourceCatalog fields.

    ``cat[name]`` works for numeric and flag columns, but LSST string fields
    (KeyString) cannot be exposed through SourceColumnView.  For those fields,
    use the Schema key to read each SourceRecord; never skip a field during the
    exact-value audit.  This also handles other non-vectorizable key types.
    """
    try:
        return np.asarray(cat[name])
    except TypeError:
        key = cat.schema.find(name).key
        return np.asarray([record.get(key) for record in cat])


def validate_catalogues(original, corrected, band, factors, context, *, roundtrip=False):
    """Check EVERY field exactly, allowing changes in only seven uncertainties.

    Free-text FITS documentation and Butler-managed provenance are allowed
    to differ ONLY during the persisted Butler read-back checks.
    """
    assert_same_structure(original, corrected, context, roundtrip=roundtrip)
    for name in original.schema.getNames():
        old = get_field_values(original, name)
        new = get_field_values(corrected, name)
        if old.dtype != new.dtype or old.shape != new.shape:
            raise AssertionError(f"{context}: dtype/shape changed: {name}")
        if name in ALL_CORRECTED_FIELDS:
            radius = next(r for r, f in FIELDS.items() if f == name)
            exp, _ = expected_error(old, factors[(band, radius)])
            np.testing.assert_array_equal(
                new, exp,
                err_msg=f"{context}: wrong corrected values for {name}",
            )
        else:
            np.testing.assert_array_equal(
                new, old, err_msg=f"{context}: UNEXPECTED CHANGE to {name}",
            )
    # All ID/flux/flag/astrometry/other uncertainties were checked above.


def correct_catalogue(original, band, factors):
    """Deep copy the original SourceCatalog, retaining its complete schema."""
    check_schema(original, f"{band} input")
    corrected = original.copy(deep=True)
    for radius, field in FIELDS.items():
        expected, _ = expected_error(np.asarray(original[field]), factors[(band, radius)])
        corrected[field][:] = expected
    validate_catalogues(original, corrected, band, factors, f"in-memory {band}")
    return corrected


def query_input_refs(butler, types, bands, tract=None, patch=None):
    """Query only the exact original RUN; never search the corrected RUN."""
    entries = []
    for kind in types:
        original_type, source_run, output_type = INPUTS[kind]
        try:
            dt = butler.registry.getDatasetType(original_type)
        except KeyError as exc:
            raise RuntimeError(f"Original dataset type not registered: {original_type}") from exc
        LOG.info("Input %s: %s, storage class %s", kind, dt.dimensions, dt.storageClass)
        refs = list(butler.registry.queryDatasets(
            original_type,
            collections=[source_run],
            where=f"skymap='{SKYMAP}'",
        ))
        good = []
        for ref in refs:
            did = data_id(ref)
            if did["band"] not in bands:
                continue
            if tract is not None and (did["tract"], did["patch"]) != (tract, patch):
                continue
            if did["skymap"] != SKYMAP or ref.run != source_run:
                raise AssertionError("Unexpected source provenance")
            good.append((kind, ref, did))
        good.sort(key=lambda row: (
            BANDS.index(row[2]["band"]), row[2]["tract"], row[2]["patch"]
        ))
        if not good:
            raise RuntimeError(f"No input {original_type} in {source_run} for requested selection")
        ids = [(d["band"], d["tract"], d["patch"]) for _, _, d in good]
        if len(set(ids)) != len(ids):
            raise AssertionError(f"Duplicate dataset IDs in {source_run}")
        LOG.info("%s: %d input datasets, bands: %s", kind, len(good), dict(Counter(d["band"] for _,_,d in good)))
        entries.extend(good)
    return entries


def register_output(butler, types, run):
    """Create a distinct RUN; reuse the already registered original dataset types.

    Butler permits a dataset type and data ID to exist in different RUNs.
    Reusing the type avoids changing downstream readers; explicit collection
    selection distinguishes corrected output from uncorrected input.
    """
    original_runs = {spec[1] for spec in INPUTS.values()}
    if run in original_runs:
        raise ValueError(f"Refusing output RUN equal to input RUN: {run}")
    for kind in types:
        original_type, _, output_type = INPUTS[kind]
        if output_type != original_type:
            raise AssertionError("Output dataset type must match input type")
        # Already registered in this Butler repository: NEVER redefine it.
        existing_dt = butler.registry.getDatasetType(output_type)
        source_dt = butler.registry.getDatasetType(original_type)
        if (existing_dt.dimensions != source_dt.dimensions
                or existing_dt.storageClass != source_dt.storageClass):
            raise AssertionError(f"Incompatible dataset type definition: {output_type}")
    butler.registry.registerRun(run)
    LOG.info("Output RUN registered (original dataset types reused): %s", run)


def existing_ref(butler, output_type, run, did):
    refs = list(butler.registry.queryDatasets(
        output_type, collections=[run], dataId=did,
    ))
    if len(refs) > 1:
        raise AssertionError("Duplicate output datasets for same dataId in RUN")
    return refs[0] if refs else None


def audit_write(audit_path, entry):
    if audit_path is not None:
        path = Path(audit_path)
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("a", encoding="utf-8") as handle:
            handle.write(json.dumps(entry, sort_keys=True) + "\n")


def run(args):
    factors, cal_sha = read_calibration(args.calibration)
    LOG.info("Calibration: %s (SHA256 %s)", args.calibration, cal_sha)
    types = args.types
    bands = args.bands
    if (args.tract is None) != (args.patch is None):
        raise ValueError("--tract and --patch must be supplied together")
    if args.mode == "test" and (len(bands) != 1 or args.tract is not None):
        raise ValueError("Test mode selects one catalogue per type from a SINGLE --bands selection")
    if args.mode == "full" and (args.tract is not None or set(bands) != set(BANDS)):
        raise ValueError("Full mode requires all five bands and no tract/patch filter")
    if args.mode != "plan" and not args.run:
        raise ValueError("Writing requires an explicit --run")
    if args.mode == "full" and "test" in args.run.lower():
        raise ValueError("Full output RUN may not contain 'test'")
    if args.mode == "test" and "test" not in args.run.lower():
        raise ValueError("Test output RUN must contain 'test'")

    butler = Butler(args.repo, writeable=args.mode != "plan")
    entries = query_input_refs(butler, types, bands, args.tract, args.patch)
    if args.mode == "test":
        # One measured and one forced catalogue from same chosen band.
        entries = [next(entry for entry in entries if entry[0] == kind) for kind in types]
    LOG.info("Selected input catalogues: %d", len(entries))

    # Preflight: test at least one catalogue from each band and type requested.
    seen = set()
    for kind, ref, did in entries:
        key = (kind, did["band"])
        if key in seen:
            continue
        cat = butler.get(ref)
        check_schema(cat, f"{kind} {did}")
        LOG.info("Schema OK %s %s: %d sources, %d fields", kind, did["band"], len(cat), len(cat.schema.getNames()))
        seen.add(key)
        del cat
    if args.mode == "plan":
        LOG.info("PLAN ONLY: no collection registered, no catalogues changed")
        return

    register_output(butler, types, args.run)
    tally = Counter()
    for n, (kind, ref, did) in enumerate(entries, 1):
        original_type, source_run, out_type = INPUTS[kind]
        context = f"{kind} {did['band']} {did['tract']}/{did['patch']}"
        original = butler.get(ref)
        check_schema(original, context)
        out_ref = existing_ref(butler, out_type, args.run, did)
        if out_ref is not None:
            # Resume safely: NEVER assume that an existing dataset is correct.
            saved = butler.get(out_ref)
            validate_catalogues(original, saved, did["band"], factors, f"existing {context}", roundtrip=True)
            status = "verified_existing"
        else:
            corrected = correct_catalogue(original, did["band"], factors)
            out_ref = butler.put(corrected, out_type, dataId=did, run=args.run)
            saved = butler.get(out_ref)
            validate_catalogues(original, saved, did["band"], factors, f"Butler round-trip {context}", roundtrip=True)
            status = "written_verified"
            del corrected
        tally[(kind, status)] += 1
        audit_write(args.audit_log, {
            "utc": datetime.now(timezone.utc).isoformat(),
            "status": status,
            "kind": kind,
            "input_type": original_type,
            "input_run": source_run,
            "input_id": str(ref.id),
            "output_type": out_type,
            "output_run": args.run,
            "output_id": str(out_ref.id),
            "data_id": did,
            "rows": len(original),
            "fields": len(original.schema.getNames()),
            "calibration_sha256": cal_sha,
        })
        LOG.info("[%d/%d] %s %s, rows=%d", n, len(entries), status, context, len(original))
        del original, saved
        gc.collect()
    LOG.info("FINISHED %d verified catalogues: %s", len(entries), dict(tally))


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--repo", default=DEFAULT_REPO)
    parser.add_argument("--calibration", required=True, help="DP1_aperture_noise_calibration.csv")
    parser.add_argument("--mode", choices=("plan", "test", "full"), default="plan")
    parser.add_argument("--run", help="NEW Butler output RUN; required for test/full")
    parser.add_argument("--types", nargs="+", choices=tuple(INPUTS), default=list(INPUTS))
    parser.add_argument("--bands", nargs="+", choices=BANDS, default=list(BANDS))
    parser.add_argument("--tract", type=int, help="Plan mode only, alongside --patch")
    parser.add_argument("--patch", type=int, help="Plan mode only, alongside --tract")
    parser.add_argument("--audit-log", help="Append JSON lines recording verified writes and provenance")
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO, format="%(asctime)s | %(levelname)s | %(message)s")
    try:
        run(args)
    except Exception:
        LOG.exception("STOPPED: inventory, verification, or write failed. In plan mode no changes are made; already written outputs in other modes remain in their RUN.")
        raise


if __name__ == "__main__":
    main()
