# Installation

In order to make running the code reproducible we are scripting the installation. In this directory we will install each weekly as a separate directory which can then be called by the setup script.
Furthermore any processes which take more than a minute run the risk of being killed or interupted so it is better to perform all tasks using the Slurm submission system.

You should be able to perform the installation by simply submitting the Slurm script:

```Shell
qsub 0_install_stack.slurm
```

You may want to edit the weekly to the latest version in the install shell script.

We broadly follow the installation procedure described in:

https://pipelines.lsst.io/install/index.html

and

https://github.com/joshuadkitenge/LSST-RAL-ECHO-EXP

The photometric redshift estimation requires the installation of LePhare described here:

https://gitlab.lam.fr/Galaxies/LEPHARE






