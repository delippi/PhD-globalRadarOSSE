#!/bin/ksh

pdy="20180911"
cyc="06"
pull=".false."
plot_diag=".false."
plot_fort=".true."


cd /scratch4/NCEPDEV/stmp3/Donald.E.Lippi/fv3gfs_dl2rw
mkdir -p anl/rh2018/201809/${pdy}/${cyc}/ && cd anl/rh2018/201809/${pdy}/${cyc}/

if [[ $plot_diag == ".true." ]]; then
   htar -xvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/anl/rh2018/201809/${pdy}/${cyc}/fort.209.tar
   htar -xvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/anl/rh2018/201809/${pdy}/${cyc}/diag_conv_ges.${pdy}${cyc}.gz.tar
   htar -xvf /NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/anl/rh2018/201809/${pdy}/${cyc}/diag_conv_anl.${pdy}${cyc}.gz.tar
   gunzip diag_conv_ges.${pdy}${cyc}.gz
   gunzip diag_conv_anl.${pdy}${cyc}.gz



   cp /scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/gsi/ProdGSI/exec/read_diag_conv.x .
   cp /scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/gsi/ProdGSI/util/Analysis_Utilities/read_diag/namelist.conv .
   sed -i "s#infilename='./diag_conv_ges',#infilename='./diag_conv_ges.${pdy}${cyc}',#g" namelist.conv
   sed -i "s#outfilename='./results_conv_ges',#outfilename='./results_conv_ges.${pdy}${cyc}',#g" namelist.conv
   ./read_diag_conv.x



   cp /scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/py-fv3graphics/scatterObs_template.py .
   sed -i "s/@pdy@/${pdy}/g" ./scatterObs_template.py
   sed -i "s/@cyc@/${cyc}/g" ./scatterObs_template.py
   python ./scatterObs_template.py
fi


if [[ $plot_fort == ".true." ]]; then
   rwfitdir="/scratch4/NCEPDEV/fv3-cam/save/Donald.E.Lippi/PhD-globalOSSE/rwfits/"
   cp ${rwfitdir}/run_plot_rwfits_template.ksh ${rwfitdir}/run_plot_rwfits_${pdy}${cyc}.ksh
   sed -i "s/@pdy@/${pdy}/g" ${rwfitdir}/run_plot_rwfits_${pdy}${cyc}.ksh
   sed -i "s/@cyc@/${cyc}/g" ${rwfitdir}/run_plot_rwfits_${pdy}${cyc}.ksh
   ksh ${rwfitdir}/run_plot_rwfits_${pdy}${cyc}.ksh
fi

