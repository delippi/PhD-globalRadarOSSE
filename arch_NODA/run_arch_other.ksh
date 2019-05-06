#!/bin/ksh
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

pdy=20180923 #forecast pdy (begninning date)
cyc=00       #forecast cycle
FHMAX=168  #length of forecast in hours
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
copy_files="YES"
archive_files="NO"

cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/arch_NODA

script_base="arch_NODA_other"

while [ $CDATE -le $EDATE ]; do
      cp -p $script_base.ksh $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@CDATE@/$CDATE/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@SDATE@/$SDATE/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i               "s/@OFFSET@/$offset/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                     "s/@CYC@/$cyc/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i       "s/@copy_files@/$copy_files/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i "s/@archive_files@/$archive_files/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@group@/$group/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@FHMAX@/$FHMAX/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@debug@/$debug/g" $script_base.t${cyc}z.$pdy.group$group.ksh

      if [[ $debug == "NO" ]]; then
         bsub < $script_base.t${cyc}z.$pdy.group$group.ksh
      elif [[ $debug == "YES" ]]; then
         ksh $script_base.t${cyc}z.$pdy.group$group.ksh
      fi
      CDATE=`${ndate} +24 $CDATE` #increment by 24 hours
      (( offset=offset+1 )) #increment by 1 day
      (( group=group+1 )) #increment group number
done