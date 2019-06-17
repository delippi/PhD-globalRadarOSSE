#!/bin/ksh


#/gpfs/tp1/u/Binbin.Zhou/work/grid2grid/verf_g2g.met/parm/poly/how2generate_polygon.sh

input_file_path=/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/NODA-2018092300-2018100700/rh2018/201809/20180923/00/20180923/gfs.t00z.20180923.pgrb2.0p125
input_file=gfs.t00z.pgrb2.0p125.f018
mask_file=gfs.t00z.pgrb2.0p125.f018_mask_file

hsi "cd $input_file_path; cget $input_file"

cp $input_file $mask_file



#SHM
gen_vx_mask $input_file $mask_file lat_SHM.nc -type lat -thresh '>=-90&&<=-20' -name 'SHM'

#NHM
gen_vx_mask $input_file $mask_file lat_NHM.nc -type lat -thresh '>=20&&<=90' -name 'NHM'

#TRP
gen_vx_mask $input_file $mask_file lat_TRP.nc -type lat -thresh '>=-20&&<=20' -name 'TRP'

#SPR
gen_vx_mask $input_file $mask_file lat_SPR.nc -type lat -thresh '>=-90&&<=-60' -name 'SPR'

#NPR
gen_vx_mask $input_file $mask_file lat_NPR.nc -type lat -thresh '>=60&&<=90' -name 'NPR'




#NAM
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge20&&le60'
gen_vx_mask lat_band.nc lat_band.nc lat_NAM.nc -type lon -thresh 'ge-145&&le-50' -intersection -name 'NAM'

#EUR
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge25&&le70'
gen_vx_mask lat_band.nc lat_band.nc lat_EUR.nc -type lon -thresh 'ge-10&&le28' -intersection -name 'EUR'

#ASA
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge25&&le65'
gen_vx_mask lat_band.nc lat_band.nc lat_ASA.nc -type lon -thresh 'ge60&&le145' -intersection -name 'ASA'

#AUS
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge-55&&le-10'
gen_vx_mask lat_band.nc lat_band.nc lat_AUS.nc -type lon -thresh 'ge90&&le180' -intersection -name 'AUS'

#ALK
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge55&&le72'
gen_vx_mask lat_band.nc lat_band.nc lat_ALK.nc -type lon -thresh 'ge-171&&le-139' -intersection -name 'ALK'


plot_data_plane lat_NHM.nc lat_NHM.ps 'name="NHM"; level="(*,*)";'; convert -rotate "90" lat_NHM.ps lat_NHM.png
plot_data_plane lat_SHM.nc lat_SHM.ps 'name="SHM"; level="(*,*)";'; convert -rotate "90" lat_SHM.ps lat_SHM.png
plot_data_plane lat_NAM.nc lat_NAM.ps 'name="NAM"; level="(*,*)";'; convert -rotate "90" lat_NAM.ps lat_NAM.png
plot_data_plane lat_EUR.nc lat_EUR.ps 'name="EUR"; level="(*,*)";'; convert -rotate "90" lat_EUR.ps lat_EUR.png
plot_data_plane lat_AUS.nc lat_AUS.ps 'name="AUS"; level="(*,*)";'; convert -rotate "90" lat_AUS.ps lat_AUS.png
plot_data_plane lat_ASA.nc lat_ASA.ps 'name="ASA"; level="(*,*)";'; convert -rotate "90" lat_ASA.ps lat_ASA.png
plot_data_plane lat_TRP.nc lat_TRP.ps 'name="TRP"; level="(*,*)";'; convert -rotate "90" lat_TRP.ps lat_TRP.png
plot_data_plane lat_SPR.nc lat_SPR.ps 'name="SPR"; level="(*,*)";'; convert -rotate "90" lat_SPR.ps lat_SPR.png
plot_data_plane lat_NPR.nc lat_NPR.ps 'name="NPR"; level="(*,*)";'; convert -rotate "90" lat_NPR.ps lat_NPR.png
plot_data_plane lat_ALK.nc lat_ALK.ps 'name="ALK"; level="(*,*)";'; convert -rotate "90" lat_ALK.ps lat_ALK.png

