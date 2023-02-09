# Installation

In order to make running the code reprodtciblm we are scripting the installation. In this directory we will install each weekly as a separate directory which can then be called by the setup script.
Furthermore any processes which take more than a minute run the risk of being killed or interupted so it is better to perform all tasks using the Slurm submission system.

You will need to first run the sinple script which downloads the weekly install script and runs the first stage. The second stage can take more time so is submitted to Slurm.

We broadly follow the installation procedure described in:

https://pipelines.lsst.io/install/index.html

and

https://github.com/joshuadkitenge/LSST-RAL-ECHO-EXP

The photometric redshift estimation requires the installation of LePhare described here:

https://gitlab.lam.fr/Galaxies/LEPHARE





