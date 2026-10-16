#!/usr/bin/env bash

# Reconstruct all available Rubin DP2 optical CellCoadds
# for all tracts, patches and bands.

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

INPUT_DIR="data/dp2_elais"
OUTPUT_DIR="data/dp2_elais/predetection"

count=0
skipped=0

declare -A seen=()

while IFS= read -r -d '' INPUT; do

    filename="${INPUT##*/}"

    if [[ "$filename" =~ ^deep_coadd_lsst_cells_v2_tract([0-9]+)_patch([0-9]+)_([ugrizy])\.fits$ ]]; then

        tract="${BASH_REMATCH[1]}"
        patch="${BASH_REMATCH[2]}"
        band="${BASH_REMATCH[3]}"

        key="${tract}/${patch}/${band}"

        if [[ -n "${seen[$key]+x}" ]]; then
            echo "[ERROR] Duplicate input for $key"
            echo "  ${seen[$key]}"
            echo "  $INPUT"
            exit 1
        fi

        seen[$key]="$INPUT"

        # Organise outputs by band / tract / patch
        OUT_DIR="${OUTPUT_DIR}/LSSTCam-${band}/${tract}/${patch}"

        OUTPUT="${OUT_DIR}/deep_coadd_cell_predetection_${tract}_${patch}_${band}.fits"

        # Skip existing products
        if [[ -f "$OUTPUT" ]]; then
            echo "[SKIP] ${tract}/${patch}/${band}"
            ((skipped += 1))
            continue
        fi

        echo "========================================"
        echo "Tract=${tract}, Patch=${patch}, Band=${band}"
        echo "========================================"

        python reconstruct_dp2_predetection.py \
            "$INPUT" \
            "$OUTPUT"

        ((count += 1))

    fi

done < <(
    find "$INPUT_DIR" -type f \
        -name 'deep_coadd_lsst_cells_v2_tract*_patch*_*.fits' \
        -print0 | sort -z
)

echo "========================================"
echo "Reconstruction finished"
echo "New products : $count"
echo "Skipped      : $skipped"
echo "========================================"
