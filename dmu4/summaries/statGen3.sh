#!/bin/bash
export repo=/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_wide_20220930/data
echo $repo
export repoNew=/home/ir-shir1/rds/rds-iris-ip009-lT5YGmtKack/ras81/butler_full_20221201/data
echo $repoNew
echo $(date -u)

echo "VIDEO:"
echo "video postISRCCD singleFrame"
find $repo/u/ir-shir1/DRP/videoSingleFrame/20221124T141958Z/postISRCCD -name postISRCCD*.fits  | wc -l
echo "video calexp singleFrame"
find $repo/u/ir-shir1/DRP/videoSingleFrame/20221124T141958Z/calexp -name calexp*.fits  | wc -l
#echo "video calexpBack singleFrame"
#find $repo/u/ir-shir1/DRP/videoSingleFrame -name calexpBack*.fits  | wc -l
echo "video deepCoadd coaddDetect"
find $repo/u/ir-shir1/DRP/videoCoaddDetect/20221130T131608Z/deepCoadd -name deepCoadd*.fits  | wc -l
echo "video deepCoadd_forced_src multiVisit"
find $repo/u/ir-shir1/DRP/videoMultiVisit/20221204T111133Z/deepCoadd_forced_src -name deepCoadd_forced_src*.fits | wc -l

echo "VHS:"
echo "vhs postISRCCD singleFrame"
find $repo/u/ir-shir1/DRP/vhsSingleFrame/20221202T193612Z/postISRCCD -name postISRCCD*.fits  | wc -l
echo "vhs calexp singleFrame"
find $repo/u/ir-shir1/DRP/vhsSingleFrame/20221202T193612Z/calexp -name calexp*.fits  | wc -l
echo "vhs visitSummary singleFrame"
find $repo/u/ir-shir1/DRP/vhsSingleFrame/20221202T193612Z/visitSummary -name visitSummary*.fits  | wc -l
echo "video deepCoadd coaddDetect"
find $repo/u/ir-shir1/DRP/vhsCoaddDetect/20221209T131239Z/deepCoadd -name deepCoadd*.fits  | wc -l

echo "VIKING:"
echo "viking postISRCCD singleFrame"
find $repoNew/u/ir-shir1/DRP/vikingSingleFrame/20221208T120837Z/postISRCCD -name postISRCCD*.fits  | wc -l
echo "viking calexp singleFrame"
find $repoNew/u/ir-shir1/DRP/vikingSingleFrame/20221208T120837Z/calexp -name calexp*.fits  | wc -l


#echo "video directWarp videoCoaddDetect"
#find $repo/u/ir-shir1/DRP/videoCoaddDetect/20220720T183849Z/deepCoadd_directWarp -name deepCoadd_directWarp_VIRCAM*.fits | wc -l
#echo "video deepCoadd_calexp videoCoaddDetect"
#find $repo/u/ir-shir1/DRP/videoCoaddDetect/20220720T183849Z/deepCoadd_calexp -name deepCoadd_calexp*.fits | wc -l


