#!/bin/ksh

#cd /scratch4/NCEPDEV/stmp3/Donald.E.Lippi/fv3gfs_dl2rw
#pyfv3graphics="/scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/py-fv3graphics"
cd /scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/PhD-globalRadarOSSE/make_plots
pyfv3graphics="/scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/PhD-globalRadarOSSE/py-fv3graphics"
set -x

EXPS="NATURE NODA NEXRAD"
cycs="00     00   06"
pdy=20180911
FHSTART=24
#FHEND=48
(( FHEND=21+$FHSTART ))


EXPS="NATURE NODA"
cycs="00     00"
FHSTART=00
FHEND=48

EXPS="NATURE"
cycs="00"
FHSTART=00
FHEND=00

pull_or_plot="plot" #options: pull, plot
diff=".false."
field="delz"

set -A EXPS $EXPS 
set -A cycs $cycs
typeset -Z2 cyc


i=0
while [[ $i -lt ${#EXPS[@]} ]]; do
   EXP=${EXPS[${i}]}
   cyc=${cycs[${i}]}

   rm -f fv3gfs_osse_plot_${EXP}.log 

   echo "cp -p make_plots.ksh make_plots_${EXP}.ksh"
   cp -p make_plots.ksh make_plots_${EXP}.ksh
   sed -i       "s/@EXP@/${EXP}/g" make_plots_${EXP}.ksh
   sed -i      "s/@queue@/batch/g" make_plots_${EXP}.ksh
   sed -i       "s/@cyc@/${cyc}/g" make_plots_${EXP}.ksh
   sed -i    "s/@make_figs@/YES/g" make_plots_${EXP}.ksh
   sed -i         "s/@pdy@/$pdy/g" make_plots_${EXP}.ksh
   sed -i "s/@FHSTART@/$FHSTART/g" make_plots_${EXP}.ksh
   sed -i     "s/@FHEND@/$FHEND/g" make_plots_${EXP}.ksh
   sed -i       "s/@diff@/$diff/g" make_plots_${EXP}.ksh
   sed -i     "s/@field@/$field/g" make_plots_${EXP}.ksh
#   sed -i "s/@@//g" make_plots_${EXP}.ksh

   cp -p make_plots.ksh pull_fcst_${EXP}.ksh
   sed -i       "s/@EXP@/${EXP}/g" pull_fcst_${EXP}.ksh
   sed -i    "s/@queue@/service/g" pull_fcst_${EXP}.ksh
   sed -i       "s/@cyc@/${cyc}/g" pull_fcst_${EXP}.ksh
   sed -i     "s/@make_figs@/NO/g" pull_fcst_${EXP}.ksh
   sed -i         "s/@pdy@/$pdy/g" pull_fcst_${EXP}.ksh
   sed -i "s/@FHSTART@/$FHSTART/g" pull_fcst_${EXP}.ksh
   sed -i     "s/@FHEND@/$FHEND/g" pull_fcst_${EXP}.ksh
   sed -i       "s/@diff@/$diff/g" pull_fcst_${EXP}.ksh
   sed -i     "s/@field@/$field/g" make_fcst_${EXP}.ksh
#   sed -i "s/@@//g" pull_fcst_${EXP}.ksh

   cp -p ${pyfv3graphics}/threaded_fv3_2d_template_fcstonly.py ${pyfv3graphics}/threaded_fv3_2d_${EXP}.py
   sed -i "s/@EXP@/${EXP}/g" ${pyfv3graphics}/threaded_fv3_2d_${EXP}.py


   if [[ $pull_or_plot == "pull" ]]; then
      qsub pull_fcst_${EXP}.ksh
      #ksh  pull_fcst_${EXP}.ksh
   fi
   if [[ $pull_or_plot == "plot" ]]; then
      #qsub make_plots_${EXP}.ksh
      ksh  make_plots_${EXP}.ksh
   fi

   i=$(( $i + 1))
done


#for EXP cyc in $EXPS $cycs; do
#   echo $EXP $cyc
#   #cp -p make_plots.ksh make_plots_${EXP}.ksh
#   #sed -i "s/@EXP@/${EXP}/g" make_plots_${EXP}.ksh    
#done



