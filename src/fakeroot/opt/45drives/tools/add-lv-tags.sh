#!/bin/bash

BLOCK_DEVICE=$1
DB_DEVICE=$2

help(){
    echo "./add-lv-tags.sh <block device> <db device>"
    exit 1
}

get_lv_uuid(){
    local LV_UUID=$(lvs -o uuid $1 --no-headings | awk '{$1=$1};1')
    echo "$LV_UUID"
}

if [ $# -eq 0 ] || [ -z $BLOCK_DEVICE ] || [ -z $DB_DEVICE ] ; then
    echo "Incorrect number of arguments provided"
    help
fi

# Add block.db tags to existing block device
lvchange --addtag "ceph.db_device=$DB_DEVICE" $BLOCK_DEVICE
lvchange --addtag "ceph.db_uuid=$(get_lv_uuid $DB_DEVICE)" $BLOCK_DEVICE

# Get all tags from existing block device and write them to new block.db
# Both device should match except ceph.type=db and ceph.type=block

BLOCK_LV_TAGS_STRING=$(lvs -o lv_tags --no-headings $BLOCK_DEVICE | awk '{$1=$1};1')
IFS=',' read -r -a BLOCK_LV_TAGS <<< "$BLOCK_LV_TAGS_STRING"
for index in "${!BLOCK_LV_TAGS[@]}" ; do
    lvchange --addtag "${BLOCK_LV_TAGS[index]}" $DB_DEVICE
done
lvchange --deltag "ceph.type=block" $DB_DEVICE
lvchange --addtag "ceph.type=db" $DB_DEVICE