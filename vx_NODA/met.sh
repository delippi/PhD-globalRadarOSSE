#!/bin/ksh
#BSUB -P FV3GFS-T2O
#BSUB -J get
#BSUB -W 02:45                 # wall-clock time (hrs:mins)
#BSUB -n 1                     # number of tasks in job
#BSUB -R "rusage[mem=3072]"    # number of cores
#BSUB -q "dev_transfer"        # queue
#BSUB -o get.log               # output file name in which %J is replaced by the job ID
####### SUBROUTINES ################## SUBROUTINES ##################### SUBROUTINES ##########
#source ~/.bashrc
set -e
set -x
get_nature_fcst_hr(){
#GET NATURE FORECAST HOUR W.R.T. EXPERIMENT FORECAST HOUR
(( fhr_n=sdate_nature - cdate )) #subtract to get dhh (days: 10's hour: 1's hour) format.
if [[ $fhr_n -le -100 ]]; then   #if less than equal to -100 then we have at least one day offset.
   (( mod = fhr_n % 100 ))       #take modulo of 100 to get hours.
   (( whole = fhr_n / 100 ))     #take integer division to get number of days.
else
   mod=$fhr_n  #otherwise we only have hours offset.
   whole=0     #and days offset are zero.
fi
(( offset=-1*(whole*24 + mod) )) #convert number of days and hours into total hours offset.
(( fhr_n=fhr+offset )) #compute the nature fhr with respect to experiment forecast hour.
fhr_nature=$fhr_n
typeset -Z3 fhr_nature
echo fhr:$fhr, fhr_nature:$fhr_nature
}

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

####### MAIN PROGRAM ################# MAIN PROGRAM #################### MAIN PROGRAM #########
machine="SURGE"
cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/RMSD
throttle_jobs=2

if [[ $machine == "SURGE" ]]; then
   export ndate=/u/Donald.E.Lippi/bin/ndate
   STMP=/gpfs/hps2/stmp/Donald.E.Lippi
fi
if [[ $machine == "THEIA" ]]; then
   export ndate=/home/Donald.E.Lippi/bin/ndate
   STMP=/scratch4/NCEPDEV/stmp3/Donald.E.Lippi
fi

PSLOT="NODA-2018092300-2018100700"
PSLOTN="NATURE-2018092300-2018100700"
hpssbase=/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS
sdate_nature=2018092300 #start date of nature
sdate=${PDY}${cyc} #start date
edate=${sdate}     #end date; if same as sdate, then no outer loop is performed!
fhcyc=6          #frequency of cycles (6hrs)

echo $FHRLST
echo $FHRGRP
str=$FHRLST
char="_"
occur=`awk -F"${char}" '{print NF-1}' <<< "${str}"`; (( occur+=1 ))
export fhr=`echo $str | cut -f 1 -d $char | cut -c 2-4`
export fhrmax=`echo $str | cut -f $occur -d $char | cut -c 2-4`
export fhrinc=1
export RES=768
grid="0p125"
typeset -Z3 fhrmax fhr

export cdate=$sdate #initialize cdate to starting date.
pids=""
pids2=""
status=0

while [[ $cdate -le $edate ]]; do #main loop - loop over forecast cycles
   yr=`echo $cdate | cut -c 1-4`
   yrmn=`echo $cdate | cut -c 1-6`
   export pdy=`echo $cdate | cut -c 1-8`
   export cyc=`echo $cdate | cut -c 9-10`
   fhr=$fhr #000
   while [[ $fhr -le $fhrmax ]]; do #second loop - loop over forecast hours
      vdate=`$ndate +$fhr $cdate`
      valyr=`echo $vdate | cut -c 1-4`
      valyrmn=`echo $vdate | cut -c 1-6`
      valpdy=`echo $vdate | cut -c 1-8`
      valcyc=`echo $vdate | cut -c 9-10`

      #GET NATURE FORECAST HOUR W.R.T. EXPERIMENT FORECAST HOUR
      get_nature_fcst_hr #subroutine
      export fhr_nature

      if [[ $grid == "0p125" ]]; then
         hpssdir_noda="$hpssbase/$PSLOT/rh2018/$valyrmn/$pdy/$cyc/$valpdy/gfs.t${cyc}z.${pdy}.pgrb2.0p125/gfs.t${cyc}z.pgrb2.0p125.f$fhr"
         echo "rh2018/201809/20180923/00/$valpdy"
         echo "rh2018/201809/20180923/00/$valpdy"
         echo "rh2018/201809/20180923/00/$valpdy"
         echo "rh2018/201809/20180923/00/$valpdy"
         #hpssdir_nature="$hpssbase/$PSLOTN/rh2018/201809/20180923/00/$valpdy/gfs.t00z.${valpdy}.pgrb2.0p125/gfs.t00z.pgrb2.0p125.f$fhr_nature" #always t00z for 20180923 run
         hpssdir_nature="$hpssbase/$PSLOTN/rh2018/$valyrmn/20180923/00/$valpdy/gfs.t00z.${valpdy}.pgrb2.0p125/gfs.t00z.pgrb2.0p125.f$fhr_nature" #always t00z for 20180923 run
         noda=noda.t${cyc}z.pgrb2.0p125.f$fhr
         nature=nature.t00z.pgrb2.0p125.f$fhr_nature
      fi

      if [[ $fhr -le $fhrmax ]]; then #debug
      #if [[ $fhr -eq 24 ]]; then #debug
         echo "cd /gpfs/hps2/stmp/Donald.E.Lippi/$PSLOT/vrfy/rh2018/$yrmn/$pdy/$cyc"
         cd $STMP
         mkdir -p $PSLOT/vrfy/rh2018/$yrmn/$pdy/$cyc
         cd $PSLOT/vrfy/rh2018/$yrmn/$pdy/$cyc

         #pull down files from tape
         Pwd=`pwd`
         mkdir -p success
         if [[ ! -e $noda  && ! -e $Pwd/success/$noda.success ]]; then
            hsi cget $hpssdir_noda
            mv gfs.t${cyc}z.pgrb2.0p125.f$fhr ./$noda
         fi
         if [[ ! -e $nature && ! -e $Pwd/success/$noda.success ]]; then
            hsi cget $hpssdir_nature
            mv gfs.t00z.pgrb2.0p125.f$fhr_nature ./$nature
         fi
         
         #run MET
         if [[ ! -e $Pwd/success/$noda.success ]]; then
            cd $Pwd
            #echo "not finished" > $Pwd/success/$noda.success
            FCST_FILE=./${noda}
            OBS_FILE=./${nature}
            export MODEL="NODA"
            export DOMAIN="global"
            export METversion="V8.0"
            export MASKS=/gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/grid2grid/wmo_verf_g2g.v1.00/parm/
            CONFIG_FILES=/gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/vx_NODA/config
            export fcsthrs=$fhr
            grid_stat $FCST_FILE $OBS_FILE $CONFIG_FILES/GridStatConfig_ADPUPA -outdir . -v 2 #&; pids+=" $!"
            grid_stat $FCST_FILE $OBS_FILE $CONFIG_FILES/GridStatConfig_ADPSFC -outdir . -v 2 #&; pids+=" $!"
            grid_stat $FCST_FILE $OBS_FILE $CONFIG_FILES/GridStatConfig_REFC   -outdir . -v 2 #&; pids+=" $!"
            if [[ $fhr -gt 0 ]]; then
               grid_stat $FCST_FILE $OBS_FILE $CONFIG_FILES/GridStatConfig_APCP   -outdir . -v 2 #&; pids+=" $!"
            fi
            #wait4jobs $pids
            #pids=""
            if [[ $status -eq 0 ]]; then
               vx_tmp=/gpfs/hps2/stmp/Donald.E.Lippi/$PSLOT/vrfy/${pdy}${cyc}
               mkdir -p $vx_tmp
               mv grid_stat*F$fhr*.stat $vx_tmp 
               ARCH=/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/$PSLOT/vrfy${PDY0}/${pdy}${cyc}
               cd $vx_tmp 
               hsi "mkdir -p $ARCH"
               hsi "cd $ARCH; cput -P grid_stat*F$fhr*.stat"
               echo "success" > $Pwd/success/$noda.success
               cd -
            fi
         fi
      fi
      (( fhr+=fhrinc ))
   done #end second loop

   export cdate=`$ndate +$fhcyc $cdate` #update cdate by 6hours
done #end main loop

wait4jobs $pids2
pids2=""

if [[ $status -ne 0 ]]; then; exit $status; fi
echo "Successfully completed"
exit $status
