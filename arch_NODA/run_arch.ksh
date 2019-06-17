#!/bin/ksh
set -x
set -e

export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

pdy=$PDY
cyc=$cyc
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
copy_files="NO"
archive_files="YES"

if [[ $copy_files == "YES" && $archive_files == "NO"  ]]; then; copyarch="copy";    fi
if [[ $copy_files == "NO"  && $archive_files == "YES" ]]; then; copyarch="archive"; fi

cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/arch_NODA

script_base="${copyarch}_NODA"
mkdir -p $pdy/$cyc
cd $pdy/$cyc

while [ $CDATE -le $EDATE ]; do
      cp -p ../../arch_NODA.ksh $script_base.t${cyc}z.$pdy.group$group.ksh
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

if [[ $status -eq 0 ]]; then
   PSLOT=NODA-2018092300-2018100700
   ROTDIR="/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018092300/$PSLOT"
   cd $ROTDIR/gfs.$pdy/$cyc  #move to the dir
   rm -f gfs* 
   echo "success" > ./NODA-${pdy}${cyc}.success #write success file to start met jobs
   cd - #move back to where we were before.
fi

echo "Successfully completed"
exit $status
