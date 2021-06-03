# VHS catalogues and tests

In this folder we make the final VHS all field catalogues for distribution. We also present diagnostics.


## Issues and requirements

### Prototype run 2021.1

Following the 2020 VIDEO runs we conducted an all sky VHS run. 

Issues:
 - mergeCoaddDetections.py yielded very low numbers of sources and hence very small final catalogues. This issue should be fixed by adding coaddDriver.py configs to obs_vista to use image wide standard deviation for pixel detections.
