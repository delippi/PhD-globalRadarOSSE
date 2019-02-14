#!/bin/ksh
set -x
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

pdy=20180911 #forecast pdy (begninning date)
cyc=06       #forecast cycle
fcstlen=48   #length of forecast in hours
typeset -Z2 cyc

CDATE=${pdy}${cyc}
EDATE=`${ndate} +$fcstlen $CDATE` #increment by fcstlen
#CDATE=20180911$cyc
#EDATE=20180913$cyc

offset=0

#The next two lines are meant to break the task of copying files to a temp dir
#and then archiving them since there is so much data and the wall time will
#likely be >6hrs
copy_files="YES"
archive_files="NO"

cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/arch_NODA

while [ $CDATE -le $EDATE ]; do
      cp -p arch_NODA.ksh arch_NODA.t${cyc}z.$CDATE.ksh
      sed -i                 "s/@CDATE@/$CDATE/g" arch_NODA.t${cyc}z.$CDATE.ksh
      sed -i               "s/@OFFSET@/$offset/g" arch_NODA.t${cyc}z.$CDATE.ksh
      sed -i                     "s/@CYC@/$cyc/g" arch_NODA.t${cyc}z.$CDATE.ksh
      sed -i       "s/@copy_files@/$copy_files/g" arch_NODA.t${cyc}z.$CDATE.ksh
      sed -i "s/@archive_files@/$archive_files/g" arch_NODA.t${cyc}z.$CDATE.ksh

      bsub < arch_NODA.t${cyc}z.$CDATE.ksh 
      #ksh arch_NODA.t${cyc}z.$CDATE.ksh 
      CDATE=`${ndate} +24 $CDATE` #increment by 24 hours
      (( offset=offset+1 )) #increment by 1 day
done


