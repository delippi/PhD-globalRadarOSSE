#!/bin/ksh
#BSUB -P FV3GFS-T2O
#BSUB -J gfsarch.t@CYC@z.@CDATE@
#BSUB -W 06:00                    # wall-clock time (hrs:mins)
#BSUB -n 10                        # number of tasks in job
#BSUB -R "rusage[mem=8192]"       # number of cores
#BSUB -q "dev_transfer"           # queue
#BSUB -o gfsarch.t@CYC@z.@CDATE@.log      # output file name in which %J is replaced by the job ID

#set -x
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

#######  USER INPUT   ####################################
copy_files=@copy_files@
archive_files=@archive_files@
SDATE=2018091100
CDATE=@CDATE@
offset=@OFFSET@
PSLOT="NODA-${SDATE}-2018091800"
ROTDIR="/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/${SDATE}/$PSLOT"
STMP="/gpfs/hps2/stmp/$USER/"
ARCDIR="$STMP/archive/$PSLOT"
ATARDIR0="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS"
ATARDIR1="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/$PSLOT"
FHOUT_GFS=1
##########################################################

# Definition of how I will archive my data on HPSS:
#/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_NAMv4/nwrw_019/rh2015/201510/20151030
cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/arch_NODA
mkdir -p $STMP
#(( offset=($CDATE - $SDATE)/100 )) #calculate the day offset of CDATE from SDATE.
(( FH=$FHOUT_GFS + $offset*24 ))   #if offest is >0 add 24 for each day it is offset.
typeset -Z3 FH
(( FH=FH-1 ))
PDY0=`echo $SDATE | cut -c 1-8`
PDY=`echo  $CDATE | cut -c 1-8`
CYC=`echo  $CDATE | cut -c 9-10`
CYC0="00"
echo $ATARDIR
echo $ARCDIR
(( offset_low=$offset*24 ))
(( offset_high=($offset+1)*24 ))

valtime0=`${ndate} +${FH} ${PDY0}${CYC}`
valpdy0=`echo $valtime0   | cut -c 1-8`
valcyc0=`echo $valtime0   | cut -c 9-10`
valyrmon0=`echo $valtime0 | cut -c 1-6`
valmon0=`echo $valtime0   | cut -c 5-6`
valyr0=`echo $valtime0    | cut -c 1-4`

#set -x
MASTER=gfs.t${CYC}z.$PDY.master.grb2
GB0p25=gfs.t${CYC}z.$PDY.pgrb2.0p25
ATMDIR=gfs.t${CYC}z.$PDY.atm.nemsio
SFCDIR=gfs.t${CYC}z.$PDY.sfc.nemsio

while [[ $FH -ge $offset_low && $FH -lt $offset_high ]]; do
   valtime=`${ndate} +${FH} ${PDY0}${CYC}`
   valpdy=`echo $valtime   | cut -c 1-8`
   valcyc=`echo $valtime   | cut -c 9-10`
   valyrmon=`echo $valtime | cut -c 1-6`
   valmon=`echo $valtime   | cut -c 5-6`
   valyr=`echo $valtime    | cut -c 1-4`
   if [[ $FH -eq $offset_low ]]; then
      cd $STMP
      mkdir -p archive/$PSLOT
      cd $ARCDIR
      mkdir -p rh${valyr}/${valyrmon}/${valpdy}
      cd rh${valyr}/${valyrmon}/${valpdy} 
      hsi "cd $ATARDIR0; mkdir -p $PSLOT/rh${valyr}/${valyrmon}/${valpdy}"
      mkdir -p $MASTER
      mkdir -p $GB0p25
      mkdir -p $ATMDIR
      mkdir -p $SFCDIR
   fi

   if [[ $copy_files == "YES" ]]; then # these get moved at a later step
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.master.grb2f${FH}  ./$MASTER/. & ; job1=$!
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.master.grb2if${FH} ./$MASTER/. & ; job2=$!
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.pgrb2b.0p25.f${FH} ./$GB0p25/. & ; job3=$1
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.atmf${FH}.nemsio ./$ATMDIR/. &   ; job4=$1
      cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.sfcf${FH}.nemsio ./$SFCDIR/. &   ; job5=$1
      #wait $job1 $job2 $job3 $job4 $job5
      wait $job1 $job2 $job3 $job5 #don't wait on the nemsio atm file
      if [[ $FH%24 == 0 ]]; then
         wait #every 24th iteration wait for ATMDIR to copy. Don't want to spawn too many processes.
      fi
   fi

   echo $valtime
   (( FH=FH+1 ))

done

#ANALYSIS FILES
if [[ $copy_files == "YES" ]]; then
   cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.master.grb2anl  ./$MASTER/. &
   cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.pgrb2.0p25.anl  ./$GB0p25/. &
   cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.atmanl.nemsio ./$ATMDIR/. &
   cp -p ${ROTDIR}/gfs.$PDY0/$CYC/gfs.t${CYC}z.sfcanl.nemsio ./$SFCDIR/. &
   wait
fi


if [[ $archive_files == "YES" ]]; then #now sort the data into respective dirs
   htar -cvf $ATARDIR1/rh${valyr}/${valyrmon}/${valpdy}/${MASTER}.tar $MASTER &
   htar -cvf $ATARDIR1/rh${valyr}/${valyrmon}/${valpdy}/${GB0p25}.tar $GB0p25 &
   htar -cvf $ATARDIR1/rh${valyr}/${valyrmon}/${valpdy}/${ATMDIR}.tar $ATMDIR &
   htar -cvf $ATARDIR1/rh${valyr}/${valyrmon}/${valpdy}/${SFCDIR}.tar $SFCDIR &
fi


echo "Successfully completed"
exit 0
