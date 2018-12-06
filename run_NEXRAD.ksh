#!/bin/ksh

CDATE=2018091100
EDATE=2018091800
PSLOT="NEXRAD-${CDATE}-${EDATE}"
RES_DET=768 #768 #384
RES_ENS=384 #384 #192
NENS=80
GFS_CYC=4 # 0=none; 1=00z only [default]; 2=00z & 12z; 4=all cycles
fv3gfs="fv3gfs-20181022"
fcst_only=".false."
set -x
machine=`hostname | cut -c 1`
if   [[ $machine == 'l' || $machine == 's' ]]; then #LUNA or SURGE
   DIR=/gpfs/hps3/emc/meso/save/${USER}/${fv3gfs}/ush
   ICSDIR=/gpfs/hps2/ptmp/${USER}/fv3gfs_dl2rw/$CDATE/FV3ICS/$PSLOT/
   NCEPCOMROOT=/gpfs/hps/nco/ops/com
   CONFIGDIR=/gpfs/hps3/emc/meso/save/${USER}/${fv3gfs}/parm/config
   COMROT=/gpfs/hps2/ptmp/$USER/fv3gfs_dl2rw/$CDATE/
   EXPDIR=/gpfs/hps3/emc/meso/noscrub/${USER}/fv3gfs_dl2rw/${CDATE}/
elif [[ $machine == 't' ]]; then #THEIA
   DIR=/scratch4/NCEPDEV/fv3-cam/save/${USER}/${fv3gfs}/ush
   ICSDIR=/scratch4/NCEPDEV/stmp3/${USER}/FV3ICS
   NCEPCOMROOT=/scratch4/NCEPDEV/rstprod/com/
   CONFIGDIR=/scratch4/NCEPDEV/fv3-cam/save/${USER}/${fv3gfs}/parm/config
   COMROT=/scratch4/NCEPDEV/stmp3/${USER}/fv3gfs_dl2rw/$CDATE
   EXPDIR=/scratch4/NCEPDEV/fv3-cam/noscrub/${USER}/fv3gfs_dl2rw/$CDATE
fi
IDATE=$CDATE
EDATE=$EDATE
RES=$RES_DET
CDUMP='gdas'

cd $DIR

echo "--pslot $PSLOT"
echo "--configdir $CONFIGDIR"
echo "--idate $IDATE"
echo "--edate $EDATE"
echo "--icsdir $ICSDIR"
echo "--expdir $EXPDIR"
echo "--resdet $RES_DET"
echo "--resens $RES_ENS"
echo "--nens $NENS"
echo "--gfs_cyc $GFS_CYC"
echo "--comrot $COMROT"
echo "./rocoto/setup_expt.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --icsdir $ICSDIR --comrot $COMROT --expdir $EXPDIR --resdet $RES_DET --resens $RES_ENS --nens $NENS --gfs_cyc $GFS_CYC"
echo "Set up cycled experiment only (y/n)?"
read ansFCSTEXP
if [[ $ansFCSTEXP == 'y' ]]; then
   ./rocoto/setup_expt.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --icsdir $ICSDIR --comrot $COMROT --expdir $EXPDIR --resdet $RES_DET --resens $RES_ENS --nens $NENS --gfs_cyc $GFS_CYC
fi
echo "Set up cycled global workflow (y/n)?"
read ansWRKFLW
if [[ $ansWRKFLW == 'y' ]]; then
   ./rocoto/setup_workflow.py --expdir $EXPDIR/$PSLOT/
fi

echo "make rocotorun sh? (yn) >"
read ans
if [[ $ans == 'y' ]]; then
cat << 'EOF' > run.ksh
#!/bin/ksh
fv3gfs="fv3gfs-20181022"
#What machine are we on?
machine=`hostname | cut -c 1`
if [[ $machine == 'l' || $machine == 's' ]]; then #LUNA
   mesosave=/gpfs/hps3/emc/meso/save/$USER
   mesonoscrub=/gpfs/hps3/emc/meso/noscrub/${USER}
elif [[ $machine == 't' ]]; then #THEIA
   mesosave=/scratch4/NCEPDEV/fv3-cam/save/$USER
   mesonoscrub=/scratch4/NCEPDEV/fv3-cam/noscrub/$USER
fi


echo "Compile GSI? (yn) > "
read ans
if [[ $ans == 'y' ]]; then
   cd $mesosave/${fv3gfs}/sorc
   ./build_gsi.sh
   ./link_fv3gfs.sh emc cray 
   cd -
fi

CDATE=2018091100
EDATE=2018091800
PSLOT="NEXRAD-${CDATE}-${EDATE}"
EXPDIR=$mesonoscrub/fv3gfs_dl2rw/$CDATE/

$mesosave/${fv3gfs}/ush/rocoto/setup_workflow.py --expdir $EXPDIR/$PSLOT/

XML=${PSLOT}.xml
DB=${PSLOT}.db
DATE=201809110000
TASK="gfsanal"

#rocotorewind -w $XML -d $DB -c $DATE -t $TASK
rocotorun    -w $XML -d $DB
#rocotoboot   -w $XML -d $DB -c $DATE -t $TASK

EOF

mv run.ksh $EXPDIR/$PSLOT/.
fi



