#!/bin/bash
# ---------------------------------------------------------------------------
# disable_ssd_cache
# Copyright 2016, Brett Kelly <bkelly@45drives.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

usage() { # Help
        cat << EOF
        Usage:	disable_ssd_cache
		[-a] Disable cache on all ssd in server
		[-d] Disable cache on specific drive 
		[-h] Displays this message
EOF
        exit 0
}
checkroot(){
	SCRIPT_NAME=$(basename "$0")
	if [ "$EUID" -ne 0 ];then
		echo "You must have root privileges to run $SCRIPT_NAME"
		exit 0
	fi
}

ALL_FLAG=0
DEVICE_PATH=/dev
CONFIG_PATH=/etc

if [ -z $DEVICE_PATH ] || [ -z $CONFIG_PATH ];then
	echo "Both ALIAS_DEVICE_PATH and ALIAS_CONFIG_PATH must be defined"
	exit 1
fi
# checkroot
while getopts 'ad:' OPTION;do
	case ${OPTION} in
	a)
		ALL_FLAG=1
		;;
	d)
		DISK=("$OPTARG")
		if [ -b $DEVICE_PATH/$DISK ];then
			:
		else
			echo "$DISK is not present in system"
			exit 1
		fi
		;;
	esac
done

if [ $# -eq 0 ];then
	usage
fi

if [ $ALL_FLAG -eq 1 ];then
	BAYS=$((cat $CONFIG_PATH/vdev_id.conf| awk "NR>2" | wc -l) 2>/dev/null)
	i=0
	j=3
	## LOOP THROUGH BAYS
	while [ "$i" -lt $BAYS ];do
		bay=$(cat $CONFIG_PATH/vdev_id.conf | awk -v j=$j 'NR==j{print $2}')
		BAY[$i]=$bay
		let i=i+1
		let j=j+1
	done
else
	BAYS=1
	BAY=$DISK
fi

i=0
while [ "$i" -lt $BAYS ];do 
   	if [ ! -b $DEVICE_PATH/${BAY[$i]} ];then
        echo "Drive bay [${BAY[$i]}] is empty"
		:
	else
		if [ -b $DEVICE_PATH/${BAY[$i]} ];then
            if [ $(cat /sys/block/$(basename $(readlink $DEVICE_PATH/${BAY[$i]}))/queue/rotational) -eq 0 ];then
			    hdparm -W 0 $DEVICE_PATH/${BAY[$i]}
            fi
		fi
    fi
    let i=i+1
done
