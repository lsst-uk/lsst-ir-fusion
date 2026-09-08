#!/bin/bash

# Setup LSST Science pipeline environment; The weekly tag within the
# "setup.sh" file should be revised based on the installed stack
# version.
source setup.sh


# Set location of Butler
export repo=data

# Create a unique PostgreSQL namespace
timestamp=$(date +%Y%m%d_%H%M%S)
namespace="lsst_vista_dp1_${timestamp}"

# Create the Butler
mkdir "$repo"
touch "$repo/butler-seed.yaml"

cat > "$repo/butler-seed.yaml" << EOF
registry:
    db: "postgresql://128.232.226.166:5432/desc_csd3"
    namespace: "${namespace}"
EOF

butler create --seed-config $repo/butler-seed.yaml --override $repo


# Register VIRCAM
butler register-instrument $repo lsstuk.obs.vista.VIRCAM


# Make and register the all sky skymap using local config file
butler register-skymap $repo -C \
       "$OBS_VISTA_DIR/config/ComCam/makeSkyMap.py"


# Import the reference catalogues to the butler
butler register-dataset-type $repo \
       the_monster_20250219_vista SimpleCatalog htm7
cp -r ../../../dmu2/dmu2_DP1/data/video_cdfs $repo
butler ingest-files -t copy data \
       the_monster_20250219_vista refcats/video \
       data/video_cdfs/filename_to_htm.ecsv
rm -r data/video_cdfs


# Ingest the raw exposures *_st.fit
list="../../../dmu0/dmu0_VISTA/dmu0_VIDEO_CDFS/cdfs_images.txt"
chunkdir=$(mktemp -d)
split -l 50 "$list" "$chunkdir/cdfs_part_"

for f in "$chunkdir"/cdfs_part_*; do
  echo "Ingesting chunk: $f"
  butler ingest-raws "$repo" \
    --transfer copy \
    --processes 1 \
    --output-run VIRCAM/raw/video_cdfs \
    $(cat "$f")

  if [ $? -ne 0 ]; then
    echo "Chunk FAILED: $f" >> ingest_failed_chunks.log
  fi
done


# Define the visits from the ingested exposures
butler define-visits $repo VIRCAM --collections VIRCAM/raw/video_cdfs


# We don't have calibs but we need the collection for later processing
butler write-curated-calibrations $repo VIRCAM video


# Ingest confidence maps
butler register-dataset-type $repo confidence ExposureF instrument \
       band physical_filter exposure detector day_obs
butler ingest-files --formatter=lsstuk.obs.vista.VircamRawFormatter \
       $repo confidence confidence/video_cdfs \
       ../../../dmu0/dmu0_VISTA/dmu0_VIDEO_CDFS/cdfs_index_conf.ecsv -t copy
