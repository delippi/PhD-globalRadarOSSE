#!/bin/ksh -ex

# Author:   D. Lippi
# Abstract: This program takes the analysis time, creates the appropriate ob. directory and
#           pulls the appropriate nexrad file from HPSS.
# Input(s):
#           ANAL_TIME
# Output(s):
#           nam.t${CYC}z.nexrad.tm00.bufr_d


ANAL_TIME=2015103018  # Input from ../bkfiles/get_bkgnd.ksh
ANAL_TIME=2018091106  # Input from ../bkfiles/get_bkgnd.ksh

mkdir -p ./$ANAL_TIME
cd ./$ANAL_TIME

YYYY=`echo $ANAL_TIME | cut -c1-4`
  MM=`echo $ANAL_TIME | cut -c5-6`
  DD=`echo $ANAL_TIME | cut -c7-8`
 CYC=`echo $ANAL_TIME | cut -c9-10`
 PDY=`echo $ANAL_TIME | cut -c1-8`

typeset -Z2 MM
typeset -Z2 DD
typeset -Z2 CYC

if [ $CYC -ge 18 ]; then
   myrange=18-23
fi
if [ $CYC -ge 00 ]; then
   myrange=00-05
fi
if [ $CYC -ge 06 ]; then
   myrange=06-11
fi

#BASEFILE="com2_rap_prod_rap.${PDY}${myrange}.bufr.tar"
BASEFILE="gpfs_hps_nco_ops_com_rap_prod_rap.${PDY}${myrange}.bufr.tar"
BASEHPSS="/NCEPPROD/hpssprod/runhistory/rh${YYYY}/${YYYY}${MM}/${YYYY}${MM}${DD}"

#LEVEL 2 winds
htar -xvf ${BASEHPSS}/${BASEFILE} ./rap.t${CYC}z.radwnd.tm00.bufr_d

#LEVEL 3 winds
#htar -xvf ${BASEHPSS}/${BASEFILE} ./rap.t${CYC}z.nexrad.tm00.bufr_d

