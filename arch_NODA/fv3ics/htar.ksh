#!/bin/ksh
#BSUB -P FV3GFS-T2O
#BSUB -J fv3icsarch
#BSUB -W 06:00                    # wall-clock time (hrs:mins)
#BSUB -n 1                        # number of tasks in job
#BSUB -R "rusage[mem=8192]"       # number of cores
#BSUB -q "dev_transfer"           # queue
#BSUB -o fv3icsarch.log      # output file name in which %J is replaced by the job ID

set -x


HPSSDIR=/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/FV3ICS

cd /gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018091100/FV3ICS/
htar -cvf ${HPSSDIR}/NODA-2018091100-2018091800.tar NODA-2018091100-2018091800


#/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018091100/FV3ICS/NODA-2018091100-2018091800
#   |-enkf.gdas.20180911
#   |---00
#   |-----mem001
#   |-------INPUT
#   ...
#   |-----mem080
#   |-------INPUT
#
#   |-gdas.20180911
#   |---00
#   |-----INPUT

