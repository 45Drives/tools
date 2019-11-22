#!/bin/bash
# ---------------------------------------------------------------------------
# hybridtest

# Copyright 2019, Brett Kelly <bkelly@45drives.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

usage() {
        cat << EOF
Usage:
	hybridtest
	-h	Show this summary 

EOF
        exit 0
}
map(){
	mate-terminal --geometry=36x25 -e "watch -n 1 --color /opt/gtools/bin/lsdev" 2>/dev/null
	echo
}
datatest(){ #Launch Datatest. Writes & then Reads 5x 500GB File @ 1MB blocksize
	mate-terminal --geometry=50x10 -e "watch -n 1 ls -lh /$3/" 2>/dev/null
	CHECK=$(df | grep $3 | awk '{print $1}')
	if [ ! -z $CHECK ];then
		for i in 1 2 3 4 5 6; do
			echo "Writing Test File $i"
			 sudo dd if=/dev/zero of=/$3/test$i bs=$1 count=$2 2>&1 | awk 'NR==3'
		done
		echo
		for i in 1 2 3 4 5 6; do
			echo "Reading Test File $i"
			sudo dd if=/$3/test$i of=/dev/null bs=$1 2>&1 | awk 'NR==3'
		done
	else
		echo "Pool Not Mounted"
	fi
}
cleanup(){ #Destroy pool and wipe drives
	echo -e "\nAll Done\nCleaning Up....."
	sudo zpool destroy $1
}

checkroot(){
	SCRIPT_NAME=$(basename "$0")
	if [ "$EUID" -ne 0 ];then
		echo "You must have root privileges to run $SCRIPT_NAME"
		exit 0
	fi
}

AUTO_MODE=no
DISK_CONTROLLER=
RAID_LEVEL=raidz1
CHASSIS=
TEMP_MODE=no
BLOCK_SIZE=1M
COUNT=250000
SSD_COUNT=200000
TUNE=yes
VDEV_MODE=no
HYBRID=no


while getopts 'ab:n:rHh' OPTION; do
	case ${OPTION} in
	a)
		AUTO_MODE=yes
		;;
	b)
		BLOCK_SIZE=${OPTARG}
		;;
	n)
		COUNT=${OPTARG}
		;;
	r)
		RAID_LEVEL=${OPTARG}
		;;
	H)
		HYBRID=yes
		;;
	h)
		usage
		;;
	esac
done

checkroot

if [ $AUTO_MODE == yes ];then
	map 
	zcreate -b -l $RAID_LEVEL
	datatest $BLOCK_SIZE $COUNT $POOL
	cleanup $POOL
fi

if [ $HYBRID == yes ];then
    /opt/gtools/bin/hmap
    zcreate -b -l raidz2 -C hdd -n
    zcreate -b -l raidz2 -C ssd -n ssd  
	datatest $BLOCK_SIZE $COUNT zpool
	cleanup zpool
	datatest $BLOCK_SIZE $SSD_COUNT ssd
	cleanup ssd
fi
#wipedev -a

