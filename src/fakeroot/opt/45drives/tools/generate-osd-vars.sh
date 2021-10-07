#!/bin/bash
# ---------------------------------------------------------------------------
# generate-osd-vars.sh
# create host_vars file with devices and lvm_volumes aut generated if disk is presnt in bay
# Copyright 2020, Brett Kelly <bkelly@45drives.com>
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.############

# ALIAS CONFIG ENV VARIBLES
DEVICE_PATH=/dev/disk/by-vdev
CONFIG_PATH=/etc

LSI_9305="3224"
LSI_9361="3316"
LSI_9405="3616"
AV15BASE="3008"

getdrives() {
    IFS=$'\n' 
    j=0
    for i in $(cat $CONFIG_PATH/vdev_id.conf); do
	    bay=$(echo $i | grep alias | awk '{print $2}')
	    if [ ! -z "$bay" ];then 
            if [ -b $DEVICE_PATH/$bay ];then
                if [ "$CAS" == "true" ];then
                    if casadm -L -o csv | grep $(readlink $DEVICE_PATH/$bay) > /dev/null ; then
                        castype=$(casadm -L -o csv | grep $(readlink $DEVICE_PATH/$bay) | cut -d , -f 1)
                        if [ "$castype" == "core" ] ; then  
                            BAY[$j]=$(casadm -L -o csv | grep $(readlink $DEVICE_PATH/$bay) | cut -d , -f 6 | cut -d / -f 3 )
                        elif [ "$castype" == "cache" ] ; then
                            :
                        fi
                    else
                        BAY[$j]=$bay
                    fi
                else
                    BAY[$j]=$bay
                fi
            fi
	    fi
	    let j=j+1
    done
}


checkcas(){
if command -v casadm > /dev/null 2>&1 ; then
    cascheck=$(casadm -L)
    if [ "$cascheck" == "No caches running" ] ; then
        CAS="false"
    else
        CAS="true"
    fi
else
    CAS="false"
fi
}

printvars() {
    ## PRINT
    echo "---" 
    #echo "chassis_size: $CHASSIS_SIZE"
    echo "osd_auto_discovery: false"
#    echo "lvm_volumes:" 
#    for i in "${BAY[@]}";do
#        echo "  - data: $DEVICE_PATH/$i" 
#    done
    echo "" 
    echo "devices:" 
    for i in "${BAY[@]}";do
        echo "  - $DEVICE_PATH/$i" 
    done
    echo ""
    echo "#dedicated_devices:"
    echo "#  - /dev/"    
    echo ""
}

checkcas
if [ -s $CONFIG_PATH/vdev_id.conf ]; then
    getdrives
fi

printvars
