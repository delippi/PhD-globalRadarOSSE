#!/bin/ksh

CDATE=2018091100 #This signifies the beginning of spin up
EDATE=2018092300 #This signifies the end date of spin up
PSLOT="NODA-${CDATE}-${EDATE}"
RES=768 #768=13km #384=26km
GFS_CYC=1 # 0=none; 1=00z only [default]; 2=00z & 12z; 4=all cycles
fv3gfs="global-workflow-20190306"


machine=`hostname | cut -c 1`
if   [[ $machine == 'l' || $machine == 's' ]]; then #LUNA or SURGE
   DIR=/gpfs/hps3/emc/meso/save/${USER}/${fv3gfs}/ush
   ICSDIR=/gpfs/hps2/ptmp/${USER}/fv3gfs_dl2rw/FV3ICS/$CDATE/
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
mkdir -p $ICSDIR/$PSLOT
IDATE=$CDATE
EDATE=$EDATE

CDUMP='gfs'

cd $DIR

echo "--pslot $PSLOT"
echo "--configdir $CONFIGDIR"
echo "--idate $IDATE"
echo "--edate $EDATE"
echo "--res $RES"
echo "--gfs_cyc $GFS_CYC"
echo "--comrot $COMROT"
echo "--expdir $EXPDIR"
echo "./rocoto/setup_expt_fcstonly.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --comrot $COMROT --expdir $EXPDIR --res $RES --gfs_cyc $GFS_CYC"
echo "Set up forecast only experiment (y/n)?"
read ansFCSTEXP
if [[ $ansFCSTEXP == 'y' ]]; then
   ./rocoto/setup_expt_fcstonly.py --pslot $PSLOT --configdir $CONFIGDIR --idate $IDATE --edate $EDATE --comrot $COMROT --expdir $EXPDIR --res $RES --gfs_cyc $GFS_CYC
fi
echo "Set up forecast only workflow (y/n)?"
read ansWRKFLW
if [[ $ansWRKFLW == 'y' ]]; then
   ./rocoto/setup_workflow_fcstonly.py --expdir $EXPDIR/$PSLOT/
fi



echo "make rocotorun sh? (yn) >"
read ans
if [[ $ans == 'y' ]]; then
cat << EOF > run.ksh
#!/bin/ksh
fv3gfs="$fv3gfs"
#What machine are we on?
machine=`hostname | cut -c 1`
if [[ \$machine == 'l' || \$machine == 's' ]]; then #LUNA
   mesosave=/gpfs/hps3/emc/meso/save/$USER
   mesonoscrub=/gpfs/hps3/emc/meso/noscrub/${USER}
elif [[ \$machine == 't' ]]; then #THEIA
   mesosave=/scratch4/NCEPDEV/fv3-cam/save/$USER
   mesonoscrub=/scratch4/NCEPDEV/fv3-cam/noscrub/$USER
fi


echo "Compile GSI? (yn) > "
read ans
if [[ \$ans == 'y' ]]; then
   cd \$mesosave/\$fv3gfs/sorc
   ./build_gsi.sh
   ./link_fv3gfs.sh emc cray
   cd -
fi

CDATE=2018091100
EDATE=2018091800
PSLOT="NODA-${CDATE}-${EDATE}"
EXPDIR=\$mesonoscrub/fv3gfs_dl2rw/\$CDATE/

\$mesosave/\${fv3gfs}/ush/rocoto/setup_workflow_fcstonly.py --expdir \$EXPDIR/\$PSLOT/

XML=\${PSLOT}.xml
DB=\${PSLOT}.db
DATE=201809110000
TASK="gfsanal"

#rocotorewind -w \$XML -d \$DB -c \$DATE -t \$TASK
rocotorun    -w \$XML -d \$DB
#rocotoboot   -w \$XML -d \$DB -c \$DATE -t \$TASK

EOF

mv run.ksh $EXPDIR/$PSLOT/.
fi



