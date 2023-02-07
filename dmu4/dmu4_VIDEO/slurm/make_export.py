#Very simple script to make an export file for transfer to Edinburgh
import lsst.daf.butler as dafButler
import time
#Open the Butler without write access for safety
REPO="/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data"
butler = dafButler.Butler(REPO, writeable=False)
with butler.export(filename="exports_{}.yaml".format(time.strftime("%Y%m%d"))) as export:
    export.saveDatasets(butler.registry.queryDatasets(datasetType='deepCoadd_*',collections='videoMultiVisit'))
