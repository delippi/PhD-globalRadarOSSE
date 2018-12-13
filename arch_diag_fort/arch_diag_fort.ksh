#!/bin/ksh

pdy="20180911"
cyc="12"


cd /gpfs/hps2/stmp/Donald.E.Lippi/RUNDIRS/NEXRAD-2018091100-2018091800/${pdy}${cyc}/gdas/anal
hsi "cd /NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/; mkdir -p anl/rh2018/201809/${pdy}/${cyc}"
htar -cvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/anl/rh2018/201809/${pdy}/${cyc}/diag_conv_anl.${pdy}${cyc}.gz.tar diag_conv_anl.${pdy}${cyc}.gz
htar -cvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/anl/rh2018/201809/${pdy}/${cyc}/diag_conv_ges.${pdy}${cyc}.gz.tar diag_conv_ges.${pdy}${cyc}.gz
htar -cvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/anl/rh2018/201809/${pdy}/${cyc}/fort.209.tar fort.209

