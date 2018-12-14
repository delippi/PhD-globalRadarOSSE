#!/bin/ksh
#PBS -N fv3gfs_osse_post_@EXP@ 
#PBS -l walltime=2:30:00
##PBS -l vmem=3072mb
#PBS -l vmem=4gb
#PBS -l nodes=1
#PBS -q @queue@
#PBS -A fv3-cpu
#PBS -o fv3gfs_osse_plot_@EXP@.log 
#PBS -j oe
#set -x
echo "make plot/pul script start"
export ndate=/home/Donald.E.Lippi/bin/ndate
make_fig="@make_figs@"  #NO - pull down archives; YES - make figs
EXP="@EXP@" #NATURE, NODA, NEXRAD
DATES="2018091100-2018091800"
pdy=@pdy@
npdy=20180911
cyc=@cyc@
ncyc=00
diff="@diff@"

year=`echo $pdy | cut -c 1-4`
mon=`echo  $pdy | cut -c 5-6`
yrmon=${year}${mon}
NWORK="/scratch4/NCEPDEV/stmp3/Donald.E.Lippi/fv3gfs_dl2rw/${npdy}${ncyc}/NATURE-${DATES}/"
WORK="/scratch4/NCEPDEV/stmp3/Donald.E.Lippi/fv3gfs_dl2rw/${pdy}${cyc}/${EXP}-${DATES}/"
pyfv3graphics="/scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/py-fv3graphics"
FIGS="figs"

#SETUP COUNTERS
FHSTART=@FHSTART@ #00
FHEND=@FHEND@ #24
FHINC=3
FH=$FHSTART

#CALCULATE NATURE FH... HOW MANY HOURS ARE WE OFFSET FROM NATURE?
(( dpdy=pdy-npdy ))
(( dcyc=cyc-ncyc ))
(( NFH=FH+24*dpdy+dcyc ))

typeset -Z3 FH 
typeset -Z3 NFH 

valtime0=`${ndate} +$FH ${pdy}${cyc}`
valpdy0=`echo  $valtime0 | cut -c 1-8` 
valcyc0=`echo  $valtime0 | cut -c 9-10` 
valyrmon0=`echo $valtime0 | cut -c 1-6`
valyr0=`echo $valtime0 | cut -c 1-4`
valmon0=`echo  $valtime0 | cut -c 5-6`

nvaltime0=`${ndate} +$NFH ${npdy}${ncyc}`
valpdy0=`echo  $nvaltime0 | cut -c 1-8` 
nvalcyc0=`echo  $nvaltime0 | cut -c 9-10` 
nvalyrmon0=`echo $nvaltime0 | cut -c 1-6`
nvalyr0=`echo $nvaltime0 | cut -c 1-4`
nvalmon0=`echo  $nvaltime0 | cut -c 5-6`

if [[ $diff == ".true." && $EXP == "NATURE" ]];then
   exit "No need to run this for NATURE"
fi

while [[ $FH -le $FHEND ]]; do


   valtime=`${ndate} +$FH ${pdy}${cyc}`
   valpdy=`echo  $valtime | cut -c 1-8` 
   valcyc=`echo  $valtime | cut -c 9-10` 
   valyrmon=`echo $valtime | cut -c 1-6`
   valyr=`echo $valtime | cut -c 1-4`
   valmon=`echo  $valtime | cut -c 5-6`

   
   nvaltime=`${ndate} +$NFH ${npdy}${ncyc}`
   nvalpdy=`echo  $nvaltime | cut -c 1-8` 
   nvalcyc=`echo  $nvaltime | cut -c 9-10` 
   nvalyrmon=`echo $nvaltime | cut -c 1-6`
   nvalyr=`echo $nvaltime | cut -c 1-4`
   nvalmon=`echo  $nvaltime | cut -c 5-6`

   ATMNEM="gfs.t${cyc}z.${valpdy}.atm.nemsio"
   ATMNC4="gfs.t${cyc}z.${valpdy}.atm.nc4"
   NATMNEM="gfs.t${ncyc}z.${valnpdy0}.atm.nemsio"
   NATMNC4="gfs.t${ncyc}z.${nvalpdy0}.atm.nc4"

   #CREATE THE WORKSPACE
   mkdir -p $NWORK && cd $NWORK && mkdir -p $FIGS && mkdir -p $NATMNEM && mkdir -p $NATMNC4
   mkdir -p $WORK  && cd $WORK  && mkdir -p $FIGS && mkdir -p $ATMNEM  && mkdir -p $ATMNC4

   echo $FH $NFH
   HPSS="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/${EXP}-${DATES}/rh${valyr}/${valyrmon}/${valpdy}"
   NHPSS="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/NATURE-${DATES}/rh${nvalyr}/${nvalyrmon}/${nvalpdy0}"

   NEMSIO="gfs.t${cyc}z.atmf${FH}.nemsio"
   NNEMSIO="gfs.t${ncyc}z.atmf${NFH}.nemsio"
   if [[ $make_fig == "NO" ]]; then
      #DOWNLOAD NEMSIO FROM HPSS IF NOT ALREADY THERE
      cd $WORK
      if [[ ! -e $WORK/${ATMNEM}/${NEMSIO} ]]; then
         echo "htar -xvf ${HPSS}/gfs.t${cyc}z.${valpdy}.atm.nemsio.tar ${ATMNEM}/${NEMSIO}"
         htar -xvf ${HPSS}/gfs.t${cyc}z.${valpdy}.atm.nemsio.tar ${ATMNEM}/${NEMSIO}
      fi 
   
      if [[ $diff == ".true." ]]; then
         cd $NWORK
         if [[ ! -e $NWORK/${NATMNEM}/${NNEMSIO} ]]; then
            echo "htar -xvf ${NHPSS}/gfs.t${ncyc}z.${nvalpdy0}.atm.nemsio.tar ${NATMNEM}/${NNEMSIO}"
            htar -xvf ${NHPSS}/gfs.t${ncyc}z.${nvalpdy0}.atm.nemsio.tar ${NATMNEM}/${NNEMSIO}
         fi 
      fi

   fi
   if [[ $make_fig == "YES" ]]; then
      cd $WORK
      #CONVERT NEMSIO TO NC4 IF NOT ALREADY DONE
      NC4="gfs.t${cyc}z.atmf${FH}.nc4"
      if [[ ! -e $WORK/${ATMNC4}/${NC4} ]];then 
         cd ${ATMNEM} #move into the atm nemsio dir to convert to nc4
         python /home/Rahul.Mahajan/bin/nemsio2nc4.py --nemsio ${NEMSIO} 
         mv ${NC4} ../${ATMNC4}/${NC4} #move the new file to atm nc4 directory
         cd $WORK
      fi 

      if [[ $diff == ".true." ]]; then
         cd $NWORK
         #CONVERT NEMSIO TO NC4 IF NOT ALREADY DONE
         NNC4="gfs.t${ncyc}z.atmf${NFH}.nc4"
         if [[ ! -e $NWORK/${NATMNC4}/${NNC4} ]];then
            cd ${NATMNEM} #move into the atm nemsio dir to convert to nc4
            python /home/Rahul.Mahajan/bin/nemsio2nc4.py --nemsio ${NNEMSIO}
            mv ${NNC4} ../${NATMNC4}/${NNC4} #move the new file to atm nc4 directory
            cd $WORK
         fi

         
      fi

      #CREATE THE PLOT NOW IF NOT ALREADY DONE
      field="dbz"
      if [[ $diff == ".true." ]]; then
         FIG0="gfs.t${cyc}z.${pdy}${cyc}_v${valpdy}${valcyc}_atmf${FH}_${field}_againstTruth.png"
      else
         FIG0="gfs.t${cyc}z.${pdy}${cyc}_v${valpdy}${valcyc}_atmf${FH}_${field}.png"
      fi
      FIG1="${EXP}_${FIG0}"
      if [[ ! -e ./${FIGS}/${FIG1}_blah ]]; then 
         cd $WORK
         cd ${FIGS}
         datadir="${WORK}/${ATMNC4}"
         naturedir="${NWORK}/${NATMNC4}"
         input="gfs.t${cyc}z.atmf${FH}.nc4 $datadir $pdy $cyc $valpdy $valcyc $valtime $FH"
         if [[ $diff == ".true." ]]; then
            input="$input gfs.t${ncyc}z.atmf${NFH}.nc4 $naturedir $npdy $ncyc $nvalpdy $nvalcyc $nvaltime $NFH"
            python ${pyfv3graphics}/threaded_fv3_2d_diff.py $input
         else
            python ${pyfv3graphics}/threaded_fv3_2d_${EXP}.py $input 
         fi
         mv $datadir/${FIG0} ./${FIG1}
         cd $WORK
      fi
   fi
   (( FH=$FH+$FHINC ))
   (( NFH=$NFH+$FHINC ))
done

