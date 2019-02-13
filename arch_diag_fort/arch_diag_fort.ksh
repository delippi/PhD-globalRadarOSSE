#!/bin/ksh

pdy="20180911"
cyc="06"
PSLOT="NODA-2018091100-2018091800"

HPSSONE="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/"
HPSSTWO="anl/${PSLOT}/rh2018/201809/${pdy}/${cyc}"
HPSSFULL="${HPSSONE}/${HPSSTWO}"

cd /gpfs/hps2/stmp/Donald.E.Lippi/RUNDIRS/${PSLOT}/${pdy}${cyc}/gdas/anal
hsi "cd /NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/; mkdir -p anl/${PSLOT}/rh2018/201809/${pdy}/${cyc}"

htar -cvf ${HPSSFULL}/diag_conv_anl.${pdy}${cyc}.gz.tar diag_conv_anl.${pdy}${cyc}.gz
htar -cvf ${HPSSFULL}/diag_conv_ges.${pdy}${cyc}.gz.tar diag_conv_ges.${pdy}${cyc}.gz
htar -cvf ${HPSSFULL}/fort.209.tar fort.209
