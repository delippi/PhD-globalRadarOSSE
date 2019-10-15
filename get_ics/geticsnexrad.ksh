#!/bin/ksh
#BSUB -P FV3GFS-T2O
#BSUB -J fv3ics
#BSUB -W 06:00                    # wall-clock time (hrs:mins)
#BSUB -n 1                        # number of tasks in job
#BSUB -R "rusage[mem=8192]"       # number of cores
#BSUB -q "dev_transfer"           # queue
#BSUB -o fv3ics.log               # output file name in which %J is replaced by the job ID

mkdir -p /gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018092300/NEXRAD-2018092300-2018100700/gdas.20180922/18/
cd /gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018092300/NEXRAD-2018092300-2018100700/gdas.20180922/18/

htar -xvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/FV3ICS/NODA-2018091100-2018091800_ICS288.tar NODA-2018091100-2018092300/gfs.20180911/00/RERUN_RESTART
mv RERUN_RESTART RESTART
