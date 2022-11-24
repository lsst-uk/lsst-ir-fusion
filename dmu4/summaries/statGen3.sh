#!/bin/bash
export repo=/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data
echo $repo
echo $(date -u)
echo "vhs postISRCCD singleFrame"
find $repo/u/ir-shir1/DRP/singleFrame -name postISRCCD*.fits  | wc -l
echo "vhs calexp singleFrame"
find $repo/u/ir-shir1/DRP/singleFrame -name calexp*.fits  | wc -l

echo "viking postISRCCD singleFrame"
find $repo/u/ir-shir1/DRP/vikingSingleFrame/20221121T132807Z -name postISRCCD*.fits  | wc -l
echo "viking calexp singleFrame"
find $repo/u/ir-shir1/DRP/vikingSingleFrame/20221121T132807Z -name calexp*.fits  | wc -l


#echo "video directWarp videoCoaddDetect"
#find $repo/u/ir-shir1/DRP/videoCoaddDetect/20220720T183849Z/deepCoadd_directWarp -name deepCoadd_directWarp_VIRCAM*.fits | wc -l
#echo "video deepCoadd_calexp videoCoaddDetect"
#find $repo/u/ir-shir1/DRP/videoCoaddDetect/20220720T183849Z/deepCoadd_calexp -name deepCoadd_calexp*.fits | wc -l


