#!/bin/ksh


#/gpfs/tp1/u/Binbin.Zhou/work/grid2grid/verf_g2g.met/parm/poly/how2generate_polygon.sh

input_file_path=/NCEPDEV/emc-meso/5year/Donald.E.Lippi/rw_FV3GFS/NODA-2018092300-2018100700/rh2018/201809/20180923/00/20180923/gfs.t00z.20180923.pgrb2.0p125
input_file=gfs.t00z.pgrb2.0p125.f018
mask_file=gfs.t00z.pgrb2.0p125.f018_mask_file

hsi "cd $input_file_path; cget $input_file"

cp $input_file $mask_file



#SHM
gen_vx_mask $input_file $mask_file SHM.nc -type lat -thresh '>=-90&&<=-20' -name 'SHM'

#NHM
gen_vx_mask $input_file $mask_file NHM.nc -type lat -thresh '>=20&&<=90' -name 'NHM'

#TRP
gen_vx_mask $input_file $mask_file TRP.nc -type lat -thresh '>=-20&&<=20' -name 'TRP'

#SPR
gen_vx_mask $input_file $mask_file SPR.nc -type lat -thresh '>=-90&&<=-60' -name 'SPR'

#NPR
gen_vx_mask $input_file $mask_file NPR.nc -type lat -thresh '>=60&&<=90' -name 'NPR'




#NAM
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge20&&le60'
gen_vx_mask lat_band.nc lat_band.nc NAM.nc -type lon -thresh 'ge-145&&le-50' -intersection -name 'NAM'

#EUR
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge25&&le70'
gen_vx_mask lat_band.nc lat_band.nc EUR.nc -type lon -thresh 'ge-10&&le28' -intersection -name 'EUR'

#ASA
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge25&&le65'
gen_vx_mask lat_band.nc lat_band.nc ASA.nc -type lon -thresh 'ge60&&le145' -intersection -name 'ASA'

#AUS
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge-55&&le-10'
gen_vx_mask lat_band.nc lat_band.nc AUS.nc -type lon -thresh 'ge90&&le180' -intersection -name 'AUS'

#ALK
gen_vx_mask $input_file $mask_file lat_band.nc -type lat -thresh 'ge55&&le72'
gen_vx_mask lat_band.nc lat_band.nc ALK.nc -type lon -thresh 'ge-171&&le-139' -intersection -name 'ALK'


plot_data_plane NHM.nc NHM.ps 'name="NHM"; level="(*,*)";'; convert -rotate "90" NHM.ps NHM.png
plot_data_plane SHM.nc SHM.ps 'name="SHM"; level="(*,*)";'; convert -rotate "90" SHM.ps SHM.png
plot_data_plane NAM.nc NAM.ps 'name="NAM"; level="(*,*)";'; convert -rotate "90" NAM.ps NAM.png
plot_data_plane EUR.nc EUR.ps 'name="EUR"; level="(*,*)";'; convert -rotate "90" EUR.ps EUR.png
plot_data_plane AUS.nc AUS.ps 'name="AUS"; level="(*,*)";'; convert -rotate "90" AUS.ps AUS.png
plot_data_plane ASA.nc ASA.ps 'name="ASA"; level="(*,*)";'; convert -rotate "90" ASA.ps ASA.png
plot_data_plane TRP.nc TRP.ps 'name="TRP"; level="(*,*)";'; convert -rotate "90" TRP.ps TRP.png
plot_data_plane SPR.nc SPR.ps 'name="SPR"; level="(*,*)";'; convert -rotate "90" SPR.ps SPR.png
plot_data_plane NPR.nc NPR.ps 'name="NPR"; level="(*,*)";'; convert -rotate "90" NPR.ps NPR.png
plot_data_plane ALK.nc ALK.ps 'name="ALK"; level="(*,*)";'; convert -rotate "90" ALK.ps ALK.png

