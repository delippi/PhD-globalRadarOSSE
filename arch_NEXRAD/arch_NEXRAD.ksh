#!/bin/ksh
##BSUB -P FV3GFS-T2O
#BSUB -P GFS-DEV
#BSUB -J gfs@copyarch@.t@CYC@z.@CDATE@
#BSUB -W 06:00                    # wall-clock time (hrs:mins)
#BSUB -n 1                        # number of tasks in job
#BSUB -R "rusage[mem=8192]"       # number of cores
#BSUB -q "dev_transfer"           # queue
#BSUB -o gfs@copyarch@.t@CYC@z.@CDATE@.log      # output file name in which %J is replaced by the job ID

#synopsis: This script is a template used by run_arch.ksh and run_copy.ksh to copy and archive forecasts. 

set -e
set -x
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

#######  USER INPUT   ####################################
copy_files="@copy_files@"
archive_files="@archive_files@"
SDATE=@SDATE@
CDATE=@CDATE@
offset=@OFFSET@
PSLOT="NEXRAD-2018092300-2018100700"
ROTDIR="/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018092300/$PSLOT"
STMP="/gpfs/hps2/stmp/$USER/"
ARCDIR="$STMP/archive/$PSLOT"
ATARDIR0="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS"
ATARDIR1="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/$PSLOT"
FHOUT_GFS=1
FHMAX=@FHMAX@
debug="@debug@"
group=@group@
##########################################################

#SUBROUTINES #########################
wait4jobs(){
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
}
#SUBROUTINES #########################

# Definition of how I will archive my data on HPSS:
#/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_NAMv4/nwrw_019/rh2015/201510/20151030
cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/arch_NEXRAD
mkdir -p $STMP
PDY0=`echo $SDATE | cut -c 1-8`
PDY=`echo  $CDATE | cut -c 1-8`
CYC=`echo  $CDATE | cut -c 9-10`
(( FH=$FHOUT_GFS + ($offset*24-$CYC) ))   #if offest is >0 add 24 for each day it is offset.
if [[ $FH -le 0 ]]; then
   FH=1
fi
typeset -Z3 FH
(( FH=FH-1 ))
echo $ATARDIR
echo $ARCDIR
(( offset_low=($offset)*24-$CYC ))
(( offset_high=($offset+1)*24-$CYC ))

valtime0=`${ndate} +${FH} ${PDY0}${CYC}`
valpdy0=`echo $valtime0   | cut -c 1-8`
valcyc0=`echo $valtime0   | cut -c 9-10`
valyrmon0=`echo $valtime0 | cut -c 1-6`
valmon0=`echo $valtime0   | cut -c 5-6`
valyr0=`echo $valtime0    | cut -c 1-4`

MASTER=gfs.t${CYC}z.$PDY0.master.grb2
GB0p125=gfs.t${CYC}z.$PDY0.pgrb2.0p125
ATMDIR=gfs.t${CYC}z.$PDY0.atm.nemsio
SFCDIR=gfs.t${CYC}z.$PDY0.sfc.nemsio

create_paths="YES"
status=0
fortfile="YES"

while [[ $FH -ge $offset_low && $FH -lt $offset_high && $FH -le $FHMAX ]]; do
   valtime=`${ndate} +${FH} ${PDY0}${CYC}`
   valpdy=`echo $valtime   | cut -c 1-8`
   valcyc=`echo $valtime   | cut -c 9-10`
   valyrmon=`echo $valtime | cut -c 1-6`
   valmon=`echo $valtime   | cut -c 5-6`
   valyr=`echo $valtime    | cut -c 1-4`
   echo $valtime $FH $offset_low $offset_high

   #PATHx=rh${valyr}/${valyrmon}/${valpdy}
   PATHx=rh${valyr}/${valyrmon}/${PDY0}/${CYC}/${valpdy}

   if [[ $create_paths == "YES" ]]; then
      create_paths="NO" #turn off after first pass
      cd $STMP                 #/gpfs/hps2/stmp/Donald.E.Lippi/
      mkdir -p archive/$PSLOT
      cd $ARCDIR               #archive/NEXRAD-2018092300-2018100700
      mkdir -p ${PATHx} 
      cd ${PATHx}              #rh2018/201809/20180923/12/20180923
      if [[ $debug == "NO" ]]; then
         hsi "cd $ATARDIR0; mkdir -p $PSLOT/${PATHx}"
      fi
      #mkdir -p $MASTER
      mkdir -p $GB0p125
      #mkdir -p $ATMDIR
      #mkdir -p $SFCDIR
   fi

################  C O P Y   F I L E S  ########################################
   if [[ $copy_files == "YES" && $debug == "NO" ]]; then # these get moved at a later step

      if [[ $fortfile == "YES" && $valtime -eq ${PDY0}${CYC} ]]; then #not sure if this is right 
         cd $ARCDIR/$PATHx/..
         rsync -t $STMP/RUNDIRS/$PSLOT/${PDY0}${CYC}/gfs/*gfsanal*/fort.209   ./gfs.fort.209
         rsync -t $STMP/RUNDIRS/$PSLOT/${PDY0}${CYC}/gfs/*gfsanal*/diag_conv_anl.${PDY0}${CYC}.gz ./gfs.diag_conv_anl.${PDY0}${CYC}.gz
         rsync -t $STMP/RUNDIRS/$PSLOT/${PDY0}${CYC}/gfs/*gfsanal*/diag_conv_ges.${PDY0}${CYC}.gz ./gfs.diag_conv_ges.${PDY0}${CYC}.gz

         rsync -t $STMP/RUNDIRS/$PSLOT/${PDY0}${CYC}/gdas/*gdasanal*/fort.209 ./gdas.fort.209
         rsync -t $STMP/RUNDIRS/$PSLOT/${PDY0}${CYC}/gdas/*gdasanal*/diag_conv_anl.${PDY0}${CYC}.gz ./gdas.diag_conv_anl.${PDY0}${CYC}.gz
         rsync -t $STMP/RUNDIRS/$PSLOT/${PDY0}${CYC}/gdas/*gdasanal*/diag_conv_ges.${PDY0}${CYC}.gz ./gdas.diag_conv_ges.${PDY0}${CYC}.gz
         fortfile="NO"
      fi

      cd $ARCDIR/$PATHx
      #rsync -t ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.master.grb2f${FH} ./$MASTER/. & ; job1=$!
      rsync -t ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.pgrb2.0p125.f${FH} ./$GB0p125/. & ; job2=$!
      #rsync -t ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.atmf${FH}.nemsio  ./$ATMDIR/. & ; job3=$!
      #rsync -t ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.sfcf${FH}.nemsio  ./$SFCDIR/. & ; job4=$!
      wait $job2
   fi

################  A R C H I V E   F I L E S  ########################################
   if [[ $archive_files == "YES" ]]; then #now sort the data into respective dirs 

      if [[ $fortfile == "YES" && $valtime -eq ${PDY0}${CYC} ]]; then #not sure if this is right 
         cd $ARCDIR/$PATHx/..
         hsi "cd $ATARDIR1/$PATHx/..; cput -P  gfs.fort.209"
         hsi "cd $ATARDIR1/$PATHx/..; cput -P  gfs.diag_conv_anl.${PDY0}${CYC}.gz"
         hsi "cd $ATARDIR1/$PATHx/..; cput -P  gfs.diag_conv_ges.${PDY0}${CYC}.gz"

         hsi "cd $ATARDIR1/$PATHx/..; cput -P gdas.fort.209"
         hsi "cd $ATARDIR1/$PATHx/..; cput -P gdas.diag_conv_anl.${PDY0}${CYC}.gz "
         hsi "cd $ATARDIR1/$PATHx/..; cput -P gdas.diag_conv_ges.${PDY0}${CYC}.gz "
         fortfile="NO"
      fi

      pids=""

      #cd $ARCDIR/$PATHx/$MASTER
      #hsi "cd $ATARDIR1/$PATHx; cput -P $MASTER/gfs.t${CYC}z.master.grb2f${FH}"  &; job=$!
      #pids+=" $job"; echo "master: $job"

      cd $ARCDIR/$PATHx/$GB0p125
      hsi "cd $ATARDIR1/$PATHx; cput -P $GB0p125/gfs.t${CYC}z.pgrb2.0p125.f${FH}" &; job=$!
      pids+=" $job"; echo "0p125 job id: $job"

      #cd $ARCDIR/$PATHx/$ATMDIR
      #hsi "cd $ATARDIR1/$PATHx; cput -P $ATMDIR/gfs.t${CYC}z.atmf${FH}.nemsio"   &; job=$!
      #pids2+=" $job"; echo "atm job id: $job"

      #cd $ARCDIR/$PATHx/$SFCDIR
      #hsi "cd $ATARDIR1/$PATHx; cput -P $SFCDIR/gfs.t${CYC}z.sfcf${FH}.nemsio"   &; job=$!
      #pids+=" $job"; echo "sfc job id: $job"

      wait4jobs $pids
      pids=""

   fi
   (( FH=FH+1 ))
done

exit $status
echo "Successfully completed"
