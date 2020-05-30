#!/bin/bash
# ---------------------------------------------------------------------------
# generate-osd-vars.sh
# create host_vars file with devices and lvm_volumes aut generated if disk is presnt in bay
# Copyright 2020, Brett Kelly <bkelly@45drives.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.############

DEVICE_PATH=$ALIAS_DEVICE_PATH
CONFIG_PATH=$ALIAS_CONFIG_PATH
if [ -z $DEVICE_PATH ] || [ -z $CONFIG_PATH ];then
        DEVICE_PATH=/dev
	    CONFIG_PATH=/etc
fi

IFS=$'\n' 
j=0
for i in $(cat $CONFIG_PATH/vdev_id.conf); do
	bay=$(echo $i | grep alias | awk '{print $2}')
	if [ ! -z "$bay" ];then 
        if [ -b $DEVICE_PATH/$bay ];then
            BAY[$j]=$bay
        fi
	fi
	let j=j+1
done
echo "---" 
echo "osd_auto_discovery: false"
echo "lvm_volumes:" 
for i in "${BAY[@]}";do
    echo "  - data: $DEVICE_PATH$i" 
done
echo "" 
echo "devices:" 
for i in "${BAY[@]}";do
    echo "  - $(readlink -f $DEVICE_PATH$i)" 
done
echo ""
