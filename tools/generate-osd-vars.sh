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

getdrives() {
    IFS=$'\n' 
    j=0
    # look through vdev_id.conf and get the aliases present
    for i in $(cat $CONFIG_PATH/vdev_id.conf); do
	    bay=$(echo $i | grep alias | awk '{print $2}')
	    if [ ! -z "$bay" ];then 
            if [ -b $DEVICE_PATH/$bay ];then
                # there is a device plugged in
                DEV_TO_CHECK="$DEVICE_PATH/$bay"
                if ! isDedicatedDevice "${DEV_TO_CHECK}" "${array[@]}" ; then
                    # Device is not designated as a dedicated device, add it to the list of devices.
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
	    fi
	    let j=j+1
    done
}

isDedicatedDevice () {
  local d match="$1"
  shift
  for d; do [[ "$d" == "$match" ]] && return 0; done
  return 1
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
    echo "---" 
    echo "osd_auto_discovery: false"
    echo "" 
    echo "devices:" 
    for i in "${BAY[@]}";do
        echo "  - $DEVICE_PATH/$i" 
    done
    echo ""
}

helptext() {
    echo ""
    echo "generate-osd-vars.sh - outputs a list of device aliases found in /etc/vdev_id.conf in .yml syntax to stdout"
    echo "     Usage: /opt/45drives/tools/generate-osd-vars.sh [options] <dedicated_device_list>"
    echo "     options:"
    echo "     -h                          Display this help menu"
    echo "     -d                          <dedicated_device_list>"
    echo ""
    echo "     <dedicated_device_list>     A list of device paths separated by commas to EXCLUDE from the output."
    echo ""
    echo "     example: "
    echo "     /opt/45drives/tools/generate-osd-vars.sh -d /dev/disk/by-vdev/1-14,/dev/disk/by-vdev/1-15"
    echo ""
}

while getopts "d:h" opt; do
    case $opt in
        d ) set -f # disable glob
            IFS=, # split on , characters
            array=($OPTARG) ;; # use the split+glob operator
        h ) helptext
            graceful_exit ;;
        * ) helptext
            exit 1
    esac
done

checkcas
if [ -s $CONFIG_PATH/vdev_id.conf ]; then
    getdrives
fi

printvars
