#!/bin/ksh

set -x
CDATE=2018091106
CYC=`echo $CDATE | cut -c 9-10`

HPSSDIR="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/obs"
#simbufr="/scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/PhD-globalOSSE/obssim/fortran/run/simbufr"
simbufr="/scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/PhD-globalOSSE/obssim/fortran/run/simbufr"
cd $simbufr
#2018091106_fv3.t06z_drw.bufr
obs=${CDATE}_fv3.t${CYC}z_drw.bufr

htar -xvf ${HPSSDIR}/${obs}.tar
cp $obs /gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018091100/NEXRAD-2018091100-2018091800/gfs.20180911/06

