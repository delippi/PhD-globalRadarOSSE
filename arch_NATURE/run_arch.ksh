#!/bin/ksh
#set -x
export ndate=/gpfs/hps2/u/Donald.E.Lippi/bin/ndate

SDATE=2018091100
EDATE=2018091800

CDATE=$SDATE
offset=0

cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/fv3gfs-setup-exp/arch_NATURE
while [ $CDATE -le $EDATE ]; do
      cp -p arch_NATURE.ksh arch_NATURE_$CDATE.ksh
      sed -i   "s/@CDATE@/$CDATE/g" arch_NATURE_$CDATE.ksh
      sed -i "s/@OFFSET@/$offset/g" arch_NATURE_$CDATE.ksh
      bsub < arch_NATURE_$CDATE.ksh 
      #ksh arch_NATURE_$CDATE.ksh 
      CDATE=`${ndate} +24 $CDATE` #increment by 24 hours
      (( offset=offset+1 )) #increment by 1 day
done


