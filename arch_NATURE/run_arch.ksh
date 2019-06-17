#!/bin/ksh
set -x
set -e

export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

pdy=$PDY
cyc=$cyc
FHMAX=336   #length of forecast in hours
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
cleanup="YES" #careful with this! you could end up deleting everything! needs to be triple checked!

if [[ $copy_files == "YES" && $archive_files == "NO"  ]]; then; copyarch="copy";    fi
if [[ $copy_files == "NO"  && $archive_files == "YES" ]]; then; copyarch="archive"; fi

cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/arch_NATURE

script_base="${copyarch}_NATURE"
mkdir -p $pdy/$cyc
cd $pdy/$cyc

while [ $CDATE -le $EDATE ]; do
      cp -p ../../arch_NATURE.ksh $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i           "s/@copyarch@/$copyarch/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@CDATE@/$CDATE/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@SDATE@/$SDATE/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i               "s/@OFFSET@/$offset/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                     "s/@CYC@/$cyc/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i       "s/@copy_files@/$copy_files/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i "s/@archive_files@/$archive_files/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@group@/$group/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@FHMAX@/$FHMAX/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i                 "s/@debug@/$debug/g" $script_base.t${cyc}z.$pdy.group$group.ksh
      sed -i             "s/@cleanup@/$cleanup/g" $script_base.t${cyc}z.$pdy.group$group.ksh
#      if [[ $CDATE -eq $EDATE  ]]; then
#         sed -i               "s/@cleanup@/YES/g" $script_base.t${cyc}z.$pdy.group$group.ksh
#      else
#         sed -i                "s/@cleanup@/NO/g" $script_base.t${cyc}z.$pdy.group$group.ksh
#      fi

      if [[ $debug == "NO" ]]; then
         bsub -K < $script_base.t${cyc}z.$pdy.group$group.ksh &
         pids+=" $!"
      elif [[ $debug == "YES" ]]; then
         ksh $script_base.t${cyc}z.$pdy.group$group.ksh
      fi
      CDATE=`${ndate} +24 $CDATE` #increment by 24 hours
      (( offset=offset+1 )) #increment by 1 day
      (( group=group+1 )) #increment group number
done

status=0
for p in $pids; do
   if wait $p; then
      echo "Process $p success"
      (( status=status+0 ))
   else
      echo "Process $p fail"
      (( status=status+1 ))
   fi
done

if [[ $status -ne 0 ]]; then; exit $status; fi

if [[ $status -eq 0 && $cleanup == "YES" ]]; then
   echo "rm -rf $dir_to_be_cleaned_ptmp"  #area where experiment runs
   #rm -rf $dir_to_be_cleaned_ptmp
fi


echo "Successfully completed"
exit $status
