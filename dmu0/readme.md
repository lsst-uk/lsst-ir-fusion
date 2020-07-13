# DMU0 External data

In this directory we describe all the external data that is used in this database. This is data that has not bee modified by code here. Eventually there will be a protocol for how this data may either be stored locally in this directory or referenced at some accessible location.

Any data folder must contain the mapper file to tell the LSST Butler that it is a data directory accessible to the mapper:

```Shell
echo "lsst.obs.hsc.HscMapper" > DATA/_mapper
```
