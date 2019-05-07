#!/bin/ksh



#######  USER INPUT   ####################################
PSLOT="NODA-2018092300-2018100700"
ROTDIR="/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018092300/$PSLOT"
STMP="/gpfs/hps2/stmp/$USER/"
ARCDIR="$STMP/archive/$PSLOT"
##########################################################

yyyy=`echo $PDY | cut -c 1-4`
yyyymm=`echo $PDY | cut -c 1-6`

echo "cleaning up:"
echo "$ROTDIR/gfs.$PDY/$cyc"
#echo "$ROTDIR/gdas.$PDYm1/$cycm1"
echo "$ARCDIR/rh$yyyy/$yyyymm/$PDY/$cyc"

#rm -rf  $ROTDIR/gfs.$PDY/$cyc
#rm -rf  $ROTDIR/gdas.$PDYm1/$cycm1
#rm -rf  $ARCDIR/rh$yyyy/$yyyymm/$PDY/$cyc


echo "Successfully completed"
exit 0
