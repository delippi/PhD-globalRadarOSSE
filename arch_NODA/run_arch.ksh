#!/bin/ksh
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

pdy=20180913 #forecast pdy (begninning date)
cyc=06       #forecast cycle
FHMAX=48   #length of forecast in hours
group=1
debug="NO"
typeset -Z2 cyc
typeset -Z2 group

CDATE=${pdy}${cyc}
EDATE=`${ndate} +$FHMAX $CDATE` #increment by FHMAX
SDATE=${pdy}${cyc}

offset=0

#The next two lines are meant to break the task of copying files to a temp dir
#and then archiving them since there is so much data and the wall time will
#likely be >6hrs
copy_files="NO"
archive_files="YES"

cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/arch_NODA

while [ $CDATE -le $EDATE ]; do
      cp -p arch_NODA.ksh arch_NODA.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@CDATE@/$CDATE/g" arch_NODA.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@SDATE@/$SDATE/g" arch_NODA.t${cyc}z.$pdy.group$group.ksh
      sed -i               "s/@OFFSET@/$offset/g" arch_NODA.t${cyc}z.$pdy.group$group.ksh
      sed -i                     "s/@CYC@/$cyc/g" arch_NODA.t${cyc}z.$pdy.group$group.ksh
      sed -i       "s/@copy_files@/$copy_files/g" arch_NODA.t${cyc}z.$pdy.group$group.ksh
      sed -i "s/@archive_files@/$archive_files/g" arch_NODA.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@group@/$group/g" arch_NODA.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@FHMAX@/$FHMAX/g" arch_NODA.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@debug@/$debug/g" arch_NODA.t${cyc}z.$pdy.group$group.ksh

      if [[ $debug == "NO" ]]; then
         bsub < arch_NODA.t${cyc}z.$pdy.group$group.ksh
      elif [[ $debug == "YES" ]]; then
         ksh arch_NODA.t${cyc}z.$pdy.group$group.ksh
      fi
      CDATE=`${ndate} +24 $CDATE` #increment by 24 hours
      (( offset=offset+1 )) #increment by 1 day
      (( group=group+1 )) #increment group number
done
