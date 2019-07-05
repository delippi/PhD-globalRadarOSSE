#!/bin/ksh


#/gpfs/tp1/u/Binbin.Zhou/work/grid2grid/verf_g2g.met/parm/poly/how2generate_polygon.sh

input_file_path=/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/NODA-2018092300-2018100700/rh2018/201809/20180923/00/20180923/gfs.t00z.20180923.pgrb2.0p125
input_file=gfs.t00z.pgrb2.0p125.f018
mask_file=gfs.t00z.pgrb2.0p125.f018_mask_file

hsi "cd $input_file_path; cget $input_file"

cp $input_file $mask_file



#ATL
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge0&&le55'
gen_vx_mask lat_band.nc lat_band.nc ATL.nc -type lon -thresh 'ge-70&&le-10' -intersection -name 'ATL'
plot_data_plane ATL.nc ATL.ps 'name="ATL"; level="(*,*)";'; convert -rotate "90" ATL.ps ATL.png

##PAC - can't get this to work...
#gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge-55&&le55'
#gen_vx_mask lat_band.nc lat_band.nc lat_PAC1.nc -type lon -thresh 'ge150&&le180' -intersection -name 'PAC1'
#gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge-55&&le55'
#gen_vx_mask lat_band.nc lat_band.nc lat_PAC2.nc -type lon -thresh 'ge-180&&le-130' -intersection -name 'PAC2'
#gen_vx_mask lat_PAC1.nc lat_PAC2.nc lat_PAC.nc -input_field PAC1  -type grid -union -name 'PAC'
#plot_data_plane lat_PAC.nc lat_PAC.ps 'name="PAC"; level="(*,*)";'; convert -rotate "90" lat_PAC.ps lat_PAC.png

