#!/bin/ksh
#set -x
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

SDATE=2018091100
EDATE=2018091800
#EDATE=2018091100

#The next two lines are meant to break the task of copying files to a temp dir
#and then archiving them since there is so much data and the wall time will
#likely be >6hrs
copy_files="NO"
archive_files="YES"

CDATE=$SDATE
offset=0

#cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/fv3gfs-setup-exp/arch_NATURE
cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/arch_NATURE

while [ $CDATE -le $EDATE ]; do
      cp -p arch_NATURE.ksh arch_NATURE_$CDATE.ksh
      sed -i   "s/@CDATE@/$CDATE/g" arch_NATURE_$CDATE.ksh
      sed -i "s/@OFFSET@/$offset/g" arch_NATURE_$CDATE.ksh
      sed -i "s/@copy_files@/$copy_files/g" arch_NATURE_$CDATE.ksh
      sed -i "s/@archive_files@/$archive_files/g" arch_NATURE_$CDATE.ksh
      bsub < arch_NATURE_$CDATE.ksh 
      #ksh arch_NATURE_$CDATE.ksh 
      CDATE=`${ndate} +24 $CDATE` #increment by 24 hours
      (( offset=offset+1 )) #increment by 1 day
done


