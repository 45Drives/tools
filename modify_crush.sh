#!/bin/bash

ceph config set osd osd_crush_update_on_start false

mkdir .addbuckets
ceph osd getcrushmap -o .addbuckets/crush.compiled
crushtool -d .addbuckets/crush.compiled -o .addbuckets/crush.decompiled
sed -E 's/^type ([1-9][0-9]?) ([a-z|A-Z]+)$/echo "type $((\1+2)) \2"/ge' .addbuckets/crush.decompiled > .addbuckets/crush.edited
sed -E -i '/type 0 osd/a type 1 port\ntype 2 hba' .addbuckets/crush.edited
crushtool -c .addbuckets/crush.edited -o .addbuckets/crush.compiled
ceph osd setcrushmap -i .addbuckets/crush.compiled
rm -rf .addbuckets

# Add ipmi check from dmap for chassis size and allow input  like -s from dmap
# 15 -> HBA_COUNT=0
# 30 -> HBA_COUNT=1
# 45 -> HBA_COUNT=2
# 60 -> HBA_COUNT=3
HBA_COUNT=1 # Number of HBA cards - 1

for i in `seq 0 $HBA_COUNT` ; do # Create & move HBA buckets to their respective host
    ceph osd crush add-bucket $(hostname -s)-hba$i hba
    ceph osd crush move $(hostname -s)-hba$i host=$(hostname -s)
done

for j in `seq 0 $HBA_COUNT` ; do # Create & move port buckets to their respective hba 
    for i in `seq 0 3` ; do 
        ceph osd crush add-bucket $(hostname -s)-hba$j-port$i port
        ceph osd crush move $(hostname -s)-hba$j-port$i hba=$(hostname -s)-hba$j
    done
done

IFS=$'\n' 
BYTES_2_TEBI="1099511627776"
j=0
for i in $(cat /etc/vdev_id.conf); do
	bay=$(echo $i | grep alias | awk '{print $2}')
	if [ ! -z "$bay" ];then 
		BAY[$j]=$bay
	fi
	let j=j+1
done
for DRIVE in ${BAY[*]};do
    if [ -b /dev/$DRIVE ];then
	    CARD=$(echo $DRIVE | cut -d - -f 1)
        SLOT=$(echo $DRIVE | cut -d - -f 2)
        WEIGHT=$(bc <<< "scale=8; $(blockdev --getsize64 /dev/$DRIVE)/$BYTES_2_TEBI")
        HBA=$(expr $CARD - 1 )
        PORT=$(bc <<< "a=$SLOT; b=4; if ( a%b ) a/b+1 else a/b" | bc) # Divide slot by port count and round up
        ceph osd crush set $(ceph-volume lvm list $(readlink -f /dev/$DRIVE) --format json | jq -r '.[] | .[].tags["ceph.osd_id"]') $WEIGHT port=$(hostname -s)-hba$HBA-port$(( PORT - 1 ))
    fi
done
