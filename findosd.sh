#!/bin/bash
# sh findosd.sh <osd.id>
# MUST BE RUN FROM OSD HOST WHERE OSD IS LOCATED
# IF OSD HOST IS NOT THIS HOST EXIT

DEVICE_PATH=$ALIAS_DEVICE_PATH
CONFIG_PATH=$ALIAS_CONFIG_PATH
OSD_ID=$1
if [ $# -eq 0 ];then
        echo "OSD ID required <int>"
        exit 1
fi
rpm -q jq >/dev/null  || yum install jq -y
OSD_FSID=$(ceph osd find $OSD_ID 2>/dev/null | jq -r '.osd_fsid')
OSD_HOST=$(ceph osd find $OSD_ID | jq -r '.host')

if [ "$OSD_HOST" != "$(hostname)" ];then
	echo "osd.$OSD_ID is located on host=$OSD_HOST"
	exit 1
fi

OSD_VOLID=$(lvs --noheadings -o lv_name,vg_name | grep $OSD_FSID | awk '{print $2}')
OSD_DEVID=$(pvs --noheadings -o pv_name,vg_name | grep $OSD_VOLID | awk '{print $1}')

if [ -z $DEVICE_PATH ] || [ -z $CONFIG_PATH ];then
        echo "Both ALIAS_DEVICE_PATH and ALIAS_CONFIG_PATH must be defined"
        exit 1
fi
IFS=$'\n' 
j=0
for i in $(cat $CONFIG_PATH/vdev_id.conf); do
	bay=$(echo $i | grep alias | awk '{print $2}')
	if [ ! -z "$bay" ];then 
		BAY[$j]=$bay
	fi
	let j=j+1
done
for i in "${BAY[@]}";do
	#echo "$(readlink -f /dev/$i) $OSD_DEVID "
	if [ "$(readlink -f /dev/$i)" == "$OSD_DEVID" ];then
		echo $i
	fi
done
