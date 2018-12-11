#!/bin/ksh
#set -x
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

PDY=20180911
CYC=06
valtime=${PDY}${CYC}
cycles=28 #how many cycles? 1=06z; 2=06z,12z; 3=06z,12z,18z; etc.
network="nexrad"



mkdir ./simbufr && cd ./simbufr
cycle=1
while [[ $cycle -le  $cycles ]]; do

   valcyc=`echo $valtime | cut -c 9-10`

   HPSSDIR="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/obs"
   #2018091106_fv3.t06z_drw.bufr
   obs=${network}_${valtime}_fv3.t${valcyc}z_drw.bufr

   echo ""
   echo ${obs}
   htar -xvf ${HPSSDIR}/${obs}.tar
   valtime=`${ndate} +6 ${valtime}` 

   (( cycle=cycle+1 ))
done
