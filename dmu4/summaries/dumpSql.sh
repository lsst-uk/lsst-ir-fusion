#!/bin/bash
export today=20230524

#First Butler
export repo=/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930
export backupLoc=$repo/backup_$today
echo $repo
mkdir $backupLoc
cp $repo/data/gen3.sqlite3 ${backupLoc}/gen3_backup.sqlite3
sqlite3 ${backupLoc}/gen3_backup.sqlite3 .schema > ${backupLoc}/schema.sql
sqlite3 ${backupLoc}/gen3_backup.sqlite3 .dump > ${backupLoc}/dump.sql

#Repeat for second Butler
export repoNew=/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201
export backupLoc=$repoNew/backup_$today
echo $repoNew
mkdir $backupLoc
cp $repo/data/gen3.sqlite3 ${backupLoc}/gen3_backup.sqlite3
sqlite3 ${backupLoc}/gen3_backup.sqlite3 .schema > ${backupLoc}/schema.sql
sqlite3 ${backupLoc}/gen3_backup.sqlite3 .dump > ${backupLoc}/dump.sql
