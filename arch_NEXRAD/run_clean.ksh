#!/bin/ksh -x
set -x
set -e

pdy=$PDY
cyc=$cyc
PSLOT="NEXRAD-2018092300-2018100700"
typeset -Z2 cyc
ROTDIR="/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018092300/$PSLOT"

CDATE=${pdy}${cyc}
cd /gpfs/hps3/emc/meso/save/Donald.E.Lippi/PhD-globalRadarOSSE/arch_NEXRAD
cd $pdy/$cyc

cat << EOF > ./clean_NEXRAD.t${cyc}z.${CDATE}.ksh
#!/bin/ksh
#BSUB -P GFS-DEV
#BSUB -J gfsclean.t${cyc}z.${CDATE}
#BSUB -W 00:20                    # wall-clock time (hrs:mins)
#BSUB -n 1                        # number of tasks in job
#BSUB -R "rusage[mem=8192]"       # number of cores
#BSUB -q "dev_transfer"           # queue
#BSUB -o gfsclean.t${cyc}z.${CDATE}.log      # output file name in which %J is replaced by the job ID

cd $ROTDIR
rm -rf enkfgdas.$PDY/$cyc
rm -rf gdas.$PDY/$cyc
rm -rf gfs.$PDY/$cyc

cd /gpfs/hps2/stmp/Donald.E.Lippi/RUNDIRS/$PSLOT
rm -rf ${PDY}${cyc}

EOF

chmod 755 ./clean_NEXRAD.t${cyc}z.${CDATE}.ksh
bsub -K < ./clean_NEXRAD.t${cyc}z.${CDATE}.ksh
#ksh ./clean_NEXRAD.t${cyc}z.${CDATE}.ksh

