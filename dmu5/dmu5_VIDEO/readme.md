# SXDS Prototype catalogues and tests

In this folder we make the final all field catalogues for distribution. We also test the photometry here.


## Issues and requirements

What do we need to change for future reruns?

1) CModel fluxes. The CModel flux algorithm is performed in teh public HSC data and we should add it for comparison.

2) Calibrating VISTA-Z and Y against VIDEO. Since we were originally using 2MASS to calibrate JHKs we decided that the PanSTARRS would be better calibrators for Z and Y as they were closer in wavelength and deeper. However this requires the computation of colour terms and since we are now calibrating JHKs by bootstrapping against VHS it makes more sense to bootstrap VIDEO against VIDEO to get all the bands without colour terms.
