# DMU4 Example field

This is a small region in SXDS which we are using as a test region. In particular we are looking at a single VISTA tile pointing in the VIDEO VISTA-Y,J,H,Ks survey and producing a single patch within it. This is useful for development of the obs_vista package and testing the output data products against previous catalogues and reductions.

To run this example you must install the LSST stack and obs\_vista. You must also download the raw VISTA images listed in [minimal_stacks.lis](minimal_stacks.lis). You must also download the processed HSC coadds and catalogues for the given test patch (tract:8524 patch:3,5). You may also want to run more patches around this one to produce a larger catalogue. The full list of patches on this tile is produced in [../../dmu1/3_Tile_tracts_patches.ipynb](../../dmu1/3_Tile_tracts_patches.ipynb) and in json dictionary form is:

```python
'{"8766":[[2,0],[2,1],[2,2],[3,0],[3,1],[3,2],[4,0],[4,1],[4,2],[5,0],[5,1],[5,2],[6,0],[6,1],[6,2],[7,0],[7,1],[7,2],[8,0],[8,1],[8,2]],"8524":[[2,2],[2,3],[2,4],[2,5],[2,6],[2,7],[2,8],[3,2],[3,3],[3,4],[3,5],[3,6],[3,7],[3,8],[4,2],[4,3],[4,4],[4,5],[4,6],[4,7],[4,8],[5,2],[5,3],[5,4],[5,5],[5,6],[5,7],[5,8],[6,2],[6,3],[6,4],[6,5],[6,6],[6,7],[6,8],[7,2],[7,3],[7,4],[7,5],[7,6],[7,7],[7,8],[8,2],[8,3],[8,4],[8,5],[8,6],[8,7],[8,8]],"8765":[[0,0],[0,1],[0,2]],"8523":[[0,2],[0,3],[0,4],[0,5],[0,6],[0,7],[0,8]]}'
```

If everything is set up correctly the test patch will run with test shell script:

```Shell
sh test_patch.sh
```

You can then use the notebooks to investigate the data produced which will be in the form of a Butler repository in the './data' folder.