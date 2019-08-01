#!/bin/bash
# ---------------------------------------------------------------------------
# mapSAS3224 - Used by dmap to generate LSI HBA models using SAS chipset 3224 alias config

# Copyright 2016, Brett Kelly <bkelly@45drives.com> Mitch Hall <mhall@45drives.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

CHASSIS=$1
DISK_CONTROLLER=$2
OLD_MAP=$3 #either 'yes' or 'no'
CONFIG_PATH=/etc
if [ -z $CONFIG_PATH ];then
        SCRIPT_NAME=$(basename "$0")
        echo "($SCRIPT_NAME)ALIAS_CONFIG_PATH must be defined"
        exit 1
fi
usage(){
        cat << EOF
Usage: mapSAS3224 CHASSIS CONTROLLER_ID
EOF
        exit 0

}
read_card(){
        CARD=$1
        CARD_ID=$2
        PORT=1
        while [ $PORT -lt $(expr $PORT_COUNT + 1) ];do
                if [ $PORT -eq 3 ];then
                        PORT_=5
                elif [ $PORT -eq 4 ];then
                        PORT_=6
                else
                        PORT_=$PORT
                fi
                t=$((PORT_*4))
                i=1
                while [ $i -lt $(expr $DRIVE_COUNT + 1) ];do
                        if [ $PORT -eq 1 ];then
                                slot=$i
                        elif [ $PORT -eq 2 ];then
                                slot=$(expr $i + 4)
                        elif [ $PORT -eq 3 ];then
                                slot=$(expr $i + 8)
                        elif [ $PORT -eq 4 ];then
                                slot=$(expr $i + 12)
                        fi
                        if [ $i -eq 1 ];then
                                i_=2
                        elif [ $i -eq 2 ];then
                                i_=1
                        else
                                i_=$i
                        fi
                        echo "alias $CARD-$slot     /dev/disk/by-path/pci-0000:$CARD_ID-sas-phy$(expr $t - $i_)-lun-0" >> $CONFIG_PATH/vdev_id.tmp
                        let i=i+1
                done
                let PORT=PORT+1
        done

}
trimconf(){
        TRIM=$1
        echo "$(head -n -$TRIM $CONFIG_PATH/vdev_id.tmp)" > $CONFIG_PATH/vdev_id.tmp
}

if [ $# = 0 ];then
        usage
fi

if [ -e $CONFIG_PATH/vdev_id.conf ];then
        rm -f $CONFIG_PATH/vdev_id.conf
fi

PORT_COUNT=4
DRIVE_COUNT=4

echo "# by-vdev" >> $CONFIG_PATH/vdev_id.conf
echo "# name     fully qualified or base name of device link" >> $CONFIG_PATH/vdev_id.conf
case $CHASSIS in
15)
        CARD1=$(lspci | grep $DISK_CONTROLLER | awk 'NR==1{print $1}')
        read_card 1 $CARD1
        if [ $OLD_MAP == yes ];then
                trimconf 1
        fi
        ;;
30)
        CARD1=$(lspci | grep $DISK_CONTROLLER | awk 'NR==1{print $1}')
        CARD2=$(lspci | grep $DISK_CONTROLLER | awk 'NR==2{print $1}')
        read_card 1 $CARD1
        read_card 2 $CARD2
        if [ $OLD_MAP == yes ];then
                trimconf 2
        fi
        ;;
32)
    CARD1=$(lspci | grep $DISK_CONTROLLER | awk  'NR==1{print $1}')
        CARD2=$(lspci | grep $DISK_CONTROLLER | awk  'NR==2{print $1}')
        read_card 1 $CARD1
        read_card 2 $CARD2
        ;;
45)
        CARD1=$(lspci | grep $DISK_CONTROLLER | awk 'NR==1{print $1}')
        CARD2=$(lspci | grep $DISK_CONTROLLER | awk 'NR==2{print $1}')
        CARD3=$(lspci | grep $DISK_CONTROLLER | awk 'NR==3{print $1}')
        read_card 1 $CARD1
        read_card 2 $CARD2
        read_card 3 $CARD3
        if [ $OLD_MAP == yes ];then
                trimconf 3 conf
        fi
        ;;
60)
        CARD1=$(lspci | grep $DISK_CONTROLLER | awk 'NR==1{print $1}')
        CARD2=$(lspci | grep $DISK_CONTROLLER | awk 'NR==2{print $1}')
        CARD3=$(lspci | grep $DISK_CONTROLLER | awk 'NR==3{print $1}')
        CARD4=$(lspci | grep $DISK_CONTROLLER | awk 'NR==4{print $1}')
        read_card 1 $CARD1
        read_card 2 $CARD2
        read_card 3 $CARD3
        read_card 4 $CARD4
        if [ $OLD_MAP == yes ];then
                trimconf 4 conf
        fi
        ;;
esac
cat $CONFIG_PATH/vdev_id.tmp >> $CONFIG_PATH/vdev_id.conf
rm -f $CONFIG_PATH/vdev_id.tmp
