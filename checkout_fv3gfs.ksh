#!/bin/ksh

#   This script is meant to clone a new copy of the fv3gfs global workflow
#and check out the dependent submodules and their branches for my global
#radar OSSE work.

hostname=`hostname | cut -c 1`
if [[ $hostname == 'l' ]]; then
   #LUNA
   echo "We are working on LUNA"
   save=/gpfs/hps3/emc/meso/save/$USER
   ptmp=/gpfs/hps2/ptmp/$USER
   stmp=/gpfs/hps2/stmp/$USER
elif [[ $hostname == 's' ]]; then
   #SURGE
   echo "We are working on SURGE"
   save=/gpfs/hps3/emc/meso/save/$USER
   ptmp=/gpfs/hps2/ptmp/$USER
   stmp=/gpfs/hps2/stmp/$USER
fi


workflow="global-workflow-20190306"


cd $save

if [[ ! -e $workflow ]]; then #checkout the workflow
   git clone --recursive gerrit:global-workflow $workflow 
   cd $workflow
   git checkout dl2rw_global
fi


if [[ -e $workflow ]]; then
   cd $workflow
   cd sorc
   if [[ ! -e gsi.fd ]]; then 
      sh checkout.sh #should automatically select the dl2rw branch for gsi, FV3, etc.
      sh build_all.sh
      sh link_fv3gfs.sh emc cray
   fi
   echo "copy some fix files"
   cd $save/$workflow/sorc/gsi.fd/fix
   set -x
   cp $save/PhD-globalRadarOSSE/gsi_fix/global_anavinfo.l64.txt.w .
   cp $save/PhD-globalRadarOSSE/gsi_fix/radar_list .
   cp $save/PhD-globalRadarOSSE/gsi_fix/fv3_historical/global_convinfo.txt.2018022818 ./fv3_historical/.
   set +x
fi


