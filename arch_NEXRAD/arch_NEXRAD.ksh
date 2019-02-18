#!/bin/ksh
#BSUB -P FV3GFS-T2O
#BSUB -J gfsarch.t@CYC@z.@CDATE@
#BSUB -W 06:00                    # wall-clock time (hrs:mins)
#BSUB -n 10                        # number of tasks in job
#BSUB -R "rusage[mem=8192]"       # number of cores
#BSUB -q "dev_transfer"           # queue
#BSUB -o gfsarch.t@CYC@z.@CDATE@.log      # output file name in which %J is replaced by the job ID

export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

#######  USER INPUT   ####################################
copy_files="@copy_files@"
archive_files="@archive_files@"
SDATE=2018091100
CDATE=@CDATE@
offset=@OFFSET@
PSLOT="NEXRAD-${SDATE}-${EDATE}"
ROTDIR="/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/${SDATE}/$PSLOT"
STMP="/gpfs/hps2/stmp/$USER/"
ARCDIR="$STMP/archive/$PSLOT"
ATARDIR0="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS"
ATARDIR1="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/$PSLOT"
FHOUT_GFS=1
FHOUT_GFS=1
FHMAX=@FHMAX@
debug="@debug@"
group=@group@
##########################################################

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
GB0p25=gfs.t${CYC}z.$PDY0.pgrb2.0p25
ATMDIR=gfs.t${CYC}z.$PDY0.atm.nemsio
SFCDIR=gfs.t${CYC}z.$PDY0.sfc.nemsio

create_paths="YES"

while [[ $FH -ge $offset_low && $FH -lt $offset_high && $FH -le $FHMAX ]]; do
   valtime=`${ndate} +${FH} ${PDY0}${CYC}`
   #valtime=`${ndate} +${CYC} ${valtime}`
   valpdy=`echo $valtime   | cut -c 1-8`
   valcyc=`echo $valtime   | cut -c 9-10`
   valyrmon=`echo $valtime | cut -c 1-6`
   valmon=`echo $valtime   | cut -c 5-6`
   valyr=`echo $valtime    | cut -c 1-4`
   echo $valtime $FH $offset_low $offset_high

   PATHx=rh${valyr}/${valyrmon}/${valpdy}
   PATHx=rh${valyr}/${valyrmon}/${PDY0}/${CYC}/${valpdy}

   if [[ $create_paths == "YES" ]]; then
      create_paths="NO" #turn off after first pass
      cd $STMP
      mkdir -p archive/$PSLOT
      cd $ARCDIR
      mkdir -p ${PATHx}
      cd ${PATHx} 
      if [[ $debug == "NO" ]]; then
         hsi "cd $ATARDIR0; mkdir -p $PSLOT/${PATHx}"
      fi
      mkdir -p $MASTER
      mkdir -p $GB0p25
      mkdir -p $ATMDIR
      mkdir -p $SFCDIR
   fi

   if [[ $copy_files == "YES" && $debug == "NO" ]]; then # these get moved at a later step
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.master.grb2f${FH}  ./$MASTER/. & ; job1=$!
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.master.grb2if${FH} ./$MASTER/. & ; job2=$!
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.pgrb2b.0p25.f${FH} ./$GB0p25/. & ; job3=$!
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.atmf${FH}.nemsio ./$ATMDIR/. &   ; job4=$!
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.sfcf${FH}.nemsio ./$SFCDIR/. &   ; job5=$!
      #wait $job1 $job2 $job3 $job4 $job5
      wait $job1 $job2 $job3 $job5 #don't wait on the nemsio atm file
   fi

   (( FH=FH+1 ))

done

#ANALYSIS FILES
if [[ $copy_files == "YES" && $group -eq 1 ]]; then
   cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.master.grb2anl  ./$MASTER/. &
   cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.pgrb2.0p25.anl  ./$GB0p25/. &
   cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.atmanl.nemsio ./$ATMDIR/. & ; job1=$!
   cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.sfcanl.nemsio ./$SFCDIR/. &
   wait $job1
fi


if [[ $archive_files == "YES" ]]; then #now sort the data into respective dirs
   htar -cvf $ATARDIR1/${PATHx}/${MASTER}.tar $MASTER &
   htar -cvf $ATARDIR1/${PATHx}/${GB0p25}.tar $GB0p25 &
   htar -cvf $ATARDIR1/${PATHx}/${ATMDIR}.tar $ATMDIR & ; job1=$!
   htar -cvf $ATARDIR1/${PATHx}/${SFCDIR}.tar $SFCDIR &
   wait $job1
fi


echo "Successfully completed"
exit 0
