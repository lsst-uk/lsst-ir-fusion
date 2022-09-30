# DMU6 Photometric redshifts

In this directory we take the large area catalogues from DMU5 and compute photometric redshifts. At this stage this is to test performance. 



## LePhare C++ version

We are now experimenting with the LePahre c++ implementation:

https://gitlab.lam.fr/Galaxies/LEPHARE








## Previous EAZY Pype implementation

As a first pass we are using the method of Duncan et al 2017,2018. The code is available here:

https://github.com/dunkenj/eazy-pype

It is a modifcation of the EaZY code. The code there was originally optimized for the same XMM-LSS field with the same underlying data albeit with additional bands.


### Running

There is a notebook in each survey folder which creates the input catalogues, filter curve files, and config files in the data folder. The eazy pype code available here:

https://github.com/dunkenj/eazy-pype/

Should then be run with 

```Shell
pythonw eazy-pype.py -p params.py
```

Where that params file points to the correct working directory here and input table name.

See the example params file [./dmu6_VIDEO/sxds_params.py](./dmu6_VIDEO/sxds_params.py)