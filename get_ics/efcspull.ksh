#!/bin/ksh
nmem=1
typeset -Z3 nmem
hpss=/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/FV3ICS
#hsi "mkdir -p $hpss/enkfgdas.20180911/00"
cray=/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018092300/NEXRAD-2018092300-2018100700
mkdir -p $cray
cd $cray
rm -f efcsarch.grp*.ksh
memgrp=1
grp=1
typeset -Z2 grp
memstr=""
nmemstr=0
while [[ $nmem -le 80 ]]; do
   memstr="$memstr mem$nmem"
   (( nmemstr = nmemstr + 1 )) 
   if [[ $nmemstr -eq 20 ]]; then
cat <<EOF >>efcsarch.grp$grp.ksh
#!/bin/ksh
#BSUB -P FV3GFS-T2O
#BSUB -J efcsarch.grp$grp
#BSUB -W 06:00              # wall-clock time (hrs:mins)
#BSUB -n 1                  # number of tasks in job
#BSUB -R "rusage[mem=256]"  # memory
#BSUB -q "dev_transfer"     # queue
#BSUB -o efcsarch.grp$grp.log    # output file name in which %J is replaced by the job ID

set -x

memstr="$memstr"
mkdir -p $cray/enkfgdas.20180911/00
for mem in \$memstr; do
    cd $cray/enkfgdas.20180911/00
    hsi "cd $hpss/enkfgdas.20180911/00; cget -PR \$mem"
done
EOF
      bsub < efcsarch.grp$grp.ksh
      (( grp = grp + 1 ))
      nmemstr=0
      memstr=""
   fi
   (( nmem = nmem +1 ))
done
#cd $cray
#mv enkfgdas.20180911 enkfgdas.20180923
