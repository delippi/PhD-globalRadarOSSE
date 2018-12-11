#!/bin/ksh
#BSUB -P FV3GFS-T2O
#BSUB -J gfsarch.t@CYC@z.@CDATE@
#BSUB -W 06:00                    # wall-clock time (hrs:mins)
#BSUB -n 1                        # number of tasks in job
#BSUB -R "rusage[mem=8192]"       # number of cores
#BSUB -q "dev_transfer"           # queue
#BSUB -o gfsarch.t@CYC@z.@CDATE@.log      # output file name in which %J is replaced by the job ID

#set -x
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

#######  USER INPUT   ####################################
SDATE=2018091100
EDATE=2018091800
CDATE=@CDATE@
offset=@OFFSET@
PSLOT="NEXRAD-${SDATE}-${EDATE}"
ROTDIR="/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/${SDATE}/$PSLOT"
STMP="/gpfs/hps2/stmp/$USER/"
ARCDIR="$STMP/archive/$PSLOT"
ATARDIR0="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS"
ATARDIR1="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/$PSLOT"
FHMIN_GFS=0
FHMAX_GFS_00=120
FHMAX_GFS_06=120
FHMAX_GFS_12=120
FHMAX_GFS_18=120
FHOUT_GFS=1
TESTLOGS='.false.'
##########################################################

# Definition of how I will archive my data on HPSS:
#/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_NAMv4/nwrw_019/rh2015/201510/20151030
cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/fv3gfs-setup-exp/arch_${PSLOT}
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
      ATMDIR=gfs.t${CYC}z.$PDY.atm.nemsio && mkdir -p $ATMDIR
      SFCDIR=gfs.t${CYC}z.$PDY.sfc.nemsio && mkdir -p $SFCDIR
      LOGDIR=gfs.t${CYC}z.$PDY.log.nemsio && mkdir -p $LOGDIR
      ANLDIR=gfs.t${CYC}z.$PDY.anl.nemsio && mkdir -p $ANLDIR
      hsi "cd $ATARDIR0; mkdir -p $PSLOT/rh${valyr}/${valyrmon}/${valpdy}"
   fi
   atm=gfs.t${CYC}z.atmf${FH}.nemsio
   sfc=gfs.t${CYC}z.sfcf${FH}.nemsio
   log=gfs.t${CYC}z.logf${FH}.nemsio
   if [[ $TESTLOGS  == '.false.' ]]; then # these get moved at a later step

      #ATMOSPHERIC FILES
      if [[ ! -e $ATMDIR/$atm ]]; then
         cp -p ${ROTDIR}/gfs.$PDY0/$CYC/$atm ./$ATMDIR/.
      else
         echo "$LOGDIR/$atm already exists... skipping"
      fi

      #SURFACE FILES
      if [[ ! -e $SFCDIR/$sfc ]]; then
         cp -p ${ROTDIR}/gfs.$PDY0/$CYC/$sfc ./$SFCDIR/.
      else
         echo "$LOGDIR/$sfc already exists... skipping"
      fi

      #LOG FILES
      if [[ ! -e $LOGDIR/$log ]]; then
         cp -p ${ROTDIR}/gfs.$PDY0/$CYC/$log ./$LOGDIR/.
      else
         echo "$LOGDIR/$log already exists... skipping"
      fi

   else
      #LOG FILES
      if [[ ! -e $LOGDIR/$log ]]; then
         cp -p ${ROTDIR}/gfs.$PDY0/$CYC/$log ./$LOGDIR/.
      else
         echo "$LOGDIR/$log already exists... skipping"
      fi
   fi

   echo $valtime
   (( FH=FH+1 ))

done

      #ANALYSIS FILE
      anl=gfs.t${CYC}z.atmanl.nemsio
      if [[ ! -e $ANLDIR/$anl ]]; then
         cp -p ${ROTDIR}/gfs.$PDY0/$CYC/$anl ./$ANLDIR/.
      else
         echo "$ANLDIR/$anl already exists... skipping"
      fi


if [[ $TESTLOGS == '.false.' ]]; then #now sort the data into respective dirs
   htar -cvf $ATARDIR1/rh${valyr0}/${valyrmon0}/${valpdy0}/${ATMDIR}.tar $ATMDIR 
   htar -cvf $ATARDIR1/rh${valyr0}/${valyrmon0}/${valpdy0}/${SFCDIR}.tar $SFCDIR 
   htar -cvf $ATARDIR1/rh${valyr0}/${valyrmon0}/${valpdy0}/${LOGDIR}.tar $LOGDIR 
   htar -cvf $ATARDIR1/rh${valyr0}/${valyrmon0}/${valpdy0}/${ANLDIR}.tar $ANLDIR 
else
   htar -cvf $ATARDIR1/rh${valyr0}/${valyrmon0}/${valpdy0}/${LOGDIR}.tar $LOGDIR 
fi

#   ANLDIR=gfs.t${CYC}z.$PDY.atm.nemsio
#   mkdir $ANLDIR 
#   mv gfs.t${CYC}z.atma*.nemsio $ANLDIR
#   ATMDIR=gfs.t${CYC}z.$PDY.atm.nemsio
#   mkdir $ATMDIR 
#   mv gfs.t${CYC}z.atmf*.nemsio $ATMDIR
#   SFCDIR=gfs.t${CYC}z.$PDY.sfc.nemsio
#   mkdir $SFCDIR 
#   mv gfs.t${CYC}z.sfcf*.nemsio $SFCDIR
#   LOGDIR=gfs.t${CYC}z.$PDY.log.nemsio
#   mkdir $LOGDIR 
#   mv gfs.t${CYC}z.logf*.nemsio $LOGDIR
#   LOGDIR=gfs.t${CYC}z.$PDY.log.nemsio
#   mkdir $LOGDIR 
#   mv gfs.t${CYC}z.logf*.nemsio $LOGDIR


