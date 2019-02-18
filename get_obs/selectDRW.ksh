#!/bin/ksh

PSLOT="NEXRAD-2018091100-2018091800"
PSLOT="NODA-2018091100-2018091800"

#drw="2018091106_fv3.t06z_drw.bufr_4d_KGRK"
#drw="2018091106_fv3.t06z_drw.bufr_3d"
drw="2018091106_fv3.t06z_drw.bufr"
#drw="2018091106/rap.t06z.nexrad.tm00.bufr_d"

file="/gpfs/hps3/emc/meso/save/Donald.E.Lippi/fv3gfs-setup-exp/get_obs/simbufr/${drw}"

echo `du -msch $file`
dest1="/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018091100/${PSLOT}/gdas.20180911/06/gdas.t06z.drw.bufr"
dest2="/gpfs/hps2/ptmp/Donald.E.Lippi/fv3gfs_dl2rw/2018091100/${PSLOT}/gfs.20180911/06/gfs.t06z.drw.bufr"

set -x
cp $file $dest1
cp $file $dest2

