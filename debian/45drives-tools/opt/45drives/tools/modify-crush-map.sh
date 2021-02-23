#!/bin/bash
# 45Drives 2020
# Brett Kelly

usage() { # Help
        cat << EOF
    Usage:	
            [-H] HBA Count. [1,2,3,4]
            [-P] Port Count. [4,6]
            [-h] Displays this message
EOF
            exit 0
}
getcurrentmap(){
    # Get Current crush map
    mkdir -p .addbuckets
    ceph osd getcrushmap -o .addbuckets/crush.compiled > /dev/null 2>&1 
    crushtool -d .addbuckets/crush.compiled -o .addbuckets/crush.decompiled
}
checkcurrentmap(){
    TYPE_1=$(cat .addbuckets/crush.decompiled | grep -w "type 1" | awk '{print $3}') 
    TYPE_2=$(cat .addbuckets/crush.decompiled | grep -w "type 2" | awk '{print $3}')
    if [ "$TYPE_1" == "port" ] && [ "$TYPE_2" == "hba" ];then
        return 0
    else
        return 1
    fi
}
moveosds(){
    ## CREATE & MOVE HBA CRUSH BUCKETS
    for i in `seq 0 $HBA_COUNT` ; do # Create & move HBA buckets to their respective host
        ceph osd crush add-bucket $(hostname -s)-hba$i hba
        ceph osd crush move $(hostname -s)-hba$i host=$(hostname -s)
    done

    # CREATE & MOVE PORT CRUSH BUCKETS
    for j in `seq 0 $HBA_COUNT` ; do # Create & move port buckets to their respective hba
        for i in `seq 0 $PORT_COUNT` ; do
            ceph osd crush add-bucket $(hostname -s)-hba$j-port$i port
            ceph osd crush move $(hostname -s)-hba$j-port$i hba=$(hostname -s)-hba$j
        done
    done

    # MOVE OSDs INTO CORRECT hba->port BUCKETS
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
}
cleanup(){
    rm -rf .addbuckets
}

## USER INPUT
PORT_COUNT=3 # Number of Ports/HBA - 1
while getopts 'H:P:h' OPTION; do
    case ${OPTION} in
    H)
        HBA_COUNT_=${OPTARG}
        HBA_COUNT=$(($HBA_COUNT_-1))
        re='^[0-3]+$'
        if ! [[ $HBA_COUNT =~ $re ]] ;then
            echo "error: Not a valid HBA count"
            exit 1
        fi
        ;;
    P)
        PORT_COUNT_=${OPTARG}
        PORT_COUNT=$(($PORT_COUNT_-1))
        re='^(3|5)+$'
        if ! [[ $PORT_COUNT =~ $re ]] ;then
            echo "error: Not a valid PORT count"
            exit 1
        fi
        ;;
    h)
        usage
        ;;
    esac
done
if [ -z $HBA_COUNT ] ; then
    echo "error: HBA Count required"
    exit 1
fi

## DEPANDANCIES, CEPH CONNECTION and POOL CHECKS
if ! rpm -q bc >/dev/null 2>&1;then
    echo "error: Dependancy 'bc' required. yum/dnf install bc"
    exit 1
fi

if ! /usr/bin/ceph status > /dev/null; then
    echo "Does /etc/ceph/ceph.conf and /etc/ceph/ceph.client.admin.keyring exist ?"
    exit 1
fi

if [ $(ceph osd pool ls | wc -l) -gt 0 ]; then
    echo "error: Storage pools are present "
    echo "This must be run before any storage pools are created "
    exit 1
fi

if ! rpm -q ceph-osd >/dev/null 2>&1;then
    echo "error: This is not a ceph-osd node"
    exit 1
fi

if [ -z /etc/vdev_id.conf ]; then    
    echo "error: drive aliasing is not configured"
    exit 1
fi

## GET AND DECOMPILE CURRENT CRUSH MAP
getcurrentmap

## CHECK IF MAP HAS ALREADY BEEN MODIFED, MAKE MODIFICATION IF NOT
if checkcurrentmap ; then
    echo "map is already modified for port and hba"
else
    echo "map not modified for port and hba"
    sed -E 's/^type ([1-9][0-9]?) ([a-z|A-Z]+)$/echo "type $((\1+2)) \2"/ge' .addbuckets/crush.decompiled > .addbuckets/crush.edited
    sed -E -i '/type 0 osd/a type 1 port\ntype 2 hba' .addbuckets/crush.edited
    echo "injecting modified crush map..."
    crushtool -c .addbuckets/crush.edited -o .addbuckets/crush.compiled
    ceph osd setcrushmap -i .addbuckets/crush.compiled > /dev/null 2>&1 
    ceph config set osd osd_crush_update_on_start false
fi

moveosds

cleanup
