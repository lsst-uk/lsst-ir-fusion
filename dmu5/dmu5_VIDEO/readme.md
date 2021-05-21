# Prototype VISTA-HSC catalogues on the SXDS field

In this folder we make the final all field catalogues for distribution. We also characterise the photometric and astrometric solution and run further checks and diagnostics.

Please not that these are prototype catalogues. In addition to issues we have already found we anticipate further issues to be continuously discovered. We therefore ask that anybody using the catalogues take care especially when using the data to produce scientific results. However, we are hopeful that science users might test these data sets in order that they can be improved. Please contact use if you have requests for changes or additions.



## Run details

We will provide some top level details of each run that has been performed. Prototypes are named with the convention P$YEAR.$RUN. Upon start of LSST operations we anticipate producing yearly public data release runs. However in the first year it may be preferable to run additional protoytype runs with the early Rubin data products

### Prototype run 2021.1

This run was conducted in May 2021 and was over the complete overlap of HSC PDR2 and the VISTA VIDEO, VIKING, and VHS surveys. 

### Prototype run 2020.1 

This run was conducted in December 2020 and was solely over the XMM field. This run was based on VISTA Ks detections only and only included baseline measurements.

Following this first run we identified the following issues:

- 1. The run was VISTA Ks selected. The LSST Science Pipelines are explicitly designed to merge the bands into a consistent detection catalogue in order of signal to noise ratio. All future runs will use all band merges.

- 2. By default only aperture, Gaussian model, and PSF photometry is performed. For many science purposes CModel, Kron, and convolved aperture fluxes are useful. These will be added to future runs. 

- 3. The first run used the PanSTARRS zy bands to calibrate the VISTA ZY bands with a view to calculating colour terms for application after the run. WE later decided they should be directly calibrated against the previous VISTA public catalogues to maintain a consistent photometric solution.