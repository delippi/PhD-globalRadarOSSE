#!/bin/ksh


hpss=/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/FV3ICS/enkfgdas.20180911/00/mem046/RESTART
file=20180923.000000.fv_core.res.tile5.nc

cd /gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018092300/NEXRAD-2018092300-2018100700/enkfgdas.20180922/18/mem046/RESTART

hsi "cd $hpss; cget $file" 
