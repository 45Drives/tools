#!/bin/bash
DEVICE=$1
OSD_COUNT=$2
VG_NAME=db-vg1

if [ $# -eq 0 ];then
        echo "Input Required"
        echo "db-lv.sh <device> <OSD Count>"
        exit 1
fi
if [ ! -b $DEVICE ];then
        echo "$DEVICE is not present"
        exit 1
fi

pvcreate $DEVICE
vgcreate $VG_NAME $DEVICE
DB_SIZE=$((100 / $OSD_COUNT))
for i in `seq 1 $OSD_COUNT`;do
        lvcreate -n db-lv$i -l $DB_SIZE%VG $VG_NAME
done
EXTRA=$(vgs db-vg1 -o vg_free --nosuffix --noheading --units B | awk '{print $1}' | cut -d . -f 1)
EXTRA=$(( $EXTRA / 1024 ))
EXTRAosd=$(( $EXTRA / $OSD_COUNT ))
if [ $EXTRAosd -lt 4096 ];then
	exit 1
fi	
EXTRAosd=$(( $EXTRAosd - 4096 ))
for i in `seq 1 $OSD_COUNT`;do	
        lvextend -L+"$EXTRAosd"k /dev/$VG_NAME/db-lv$i
done
