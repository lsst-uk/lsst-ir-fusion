#Very simple script to make an export file for transfer to Edinburgh
import lsst.daf.butler as dafButler
import time
#Open the Butler without write access for safety
REPO="/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data"
#collection='u/ir-shir1/DRP/videoMultiVisit/20221204T111133Z'
#collection='u/ir-shir1/DRP/videoCoaddDetect/20221130T131608Z'

butler = dafButler.Butler(REPO, writeable=False)
collections=butler.registry.queryCollections()
datasetTypes=butler.registry.queryDatasetTypes()

#with butler.export(filename="exports/exports_{}.yaml".format(time.strftime("%Y%m%d"))) as export:
#    items=[]
#    for datasetType in datasetTypes:
#        found=set(butler.registry.queryDatasets(datasetType.name, collections=...))  
#        items.extend(found)  
#    export.saveDatasets(items)

with butler.export(filename="exports/exports_vhs_{}.yaml".format(time.strftime("%Y%m%d"))) as export:
    export.saveDatasets(butler.registry.queryDatasets(datasetType=...,collections='u/ir-shir1/DRP/vhsMultiVisit'))

with butler.export(filename="exports/exports_video_{}.yaml".format(time.strftime("%Y%m%d"))) as export:
    export.saveDatasets(butler.registry.queryDatasets(datasetType=...,collections='u/ir-shir1/DRP/videoMultiVisit'))



REPO2="/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/data"

butler = dafButler.Butler(REPO2, writeable=False)
collections=butler.registry.queryCollections()
datasetTypes=butler.registry.queryDatasetTypes()

#with butler.export(filename="exports/exports_{}.yaml".format(time.strftime("%Y%m%d"))) as export:
#    items=[]
#    for datasetType in datasetTypes:
#        found=set(butler.registry.queryDatasets(datasetType.name, collections=...))
#        items.extend(found)
#    export.saveDatasets(items)

with butler.export(filename="exports/exports_{}.yaml".format(time.strftime("%Y%m%d"))) as export:
    export.saveDatasets(butler.registry.queryDatasets(datasetType=...,collections='u/ir-shir1/DRP/vikingMultiVisit'))


