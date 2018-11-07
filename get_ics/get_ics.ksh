#!/bin/ksh
#BSUB -P FV3GFS-T2O
#BSUB -J fv3ics
#BSUB -W 06:00                    # wall-clock time (hrs:mins)
#BSUB -n 1                        # number of tasks in job
#BSUB -R "rusage[mem=8192]"       # number of cores
#BSUB -q "dev_transfer"           # queue
#BSUB -o fv3ics.log               # output file name in which %J is replaced by the job ID

# This script downloads initial conditions from HPSS for global radar wind assimilation experiments.
set -x

CDATE=2018091100
EDATE=2018091800
PSLOT="NEXRAD-${CDATE}-${EDATE}"

HPSSDIR="/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/FV3ICS"
ICSDIR="/gpfs/hps2/ptmp/${USER}/fv3gfs_dl2rw/$CDATE/FV3ICS/$PSLOT/"

mkdir -p $ICSDIR
cd $ICSDIR
htar -xvf ${HPSSDIR}/${PSLOT}.tar

