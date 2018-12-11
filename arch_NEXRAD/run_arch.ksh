#!/bin/ksh
set -x
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

cyc=12
typeset -Z2 cyc
CDATE=20180911$cyc
EDATE=20180916$cyc
offset=0

cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/fv3gfs-setup-exp/arch_NEXRAD
while [ $CDATE -le $EDATE ]; do
      cp -p arch_NEXRAD.ksh arch_NEXRAD.t${cyc}z.$CDATE.ksh
      sed -i   "s/@CDATE@/$CDATE/g" arch_NEXRAD.t${cyc}z.$CDATE.ksh
      sed -i "s/@OFFSET@/$offset/g" arch_NEXRAD.t${cyc}z.$CDATE.ksh
      sed -i "s/@CYC@/$cyc/g"       arch_NEXRAD.t${cyc}z.$CDATE.ksh
      bsub < arch_NEXRAD.t${cyc}z.$CDATE.ksh 
      #ksh arch_NEXRAD.t${cyc}z.$CDATE.ksh 
      CDATE=`${ndate} +24 $CDATE` #increment by 24 hours
      (( offset=offset+1 )) #increment by 1 day
done


