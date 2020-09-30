# DMU1: Data summaries

This folder, the first stage in the image processing, contains notebooks to summarise the external imaging data. These will produce some metadata files which will be used to manage the whole procedure. We will also have some diagnostics to test and verify the quality of the images.

- [1_Data_overview.ipynb](1_Data_overview.ipynb) This notebook must be run with access to all the raw data. It loops over the files and retrieves key information
- [2_Survey_comparisons.ipynb](2_Survey_comparisons.ipynb) This files checks positions and displays some information retrieved in 1. We will need to use this when building processing runs in dmu4.
- [3_Tile_tracts_patches.ipynb](3_Tile_tracts_patches.ipynb) This generates a file containing all the HSC tracts and patches that cover a given VISTA tile.


