#!/bin/bash

VDEV_RULES="https://raw.githubusercontent.com/45Drives/udev/master/69-vdev.rules"
VDEV_ID="https://raw.githubusercontent.com/45Drives/udev/master/vdev_id"

if rpm -q zfs >/dev/null 2>&1;then
	echo "ZFS is installed; quiting"
	exit 1
fi

curl -o /usr/lib/udev/rules.d/69-vdev.rules $VDEV_RULES
curl -o /usr/lib/udev/vdev_id $VDEV_ID > /dev/null ; chmod +x /usr/lib/udev/vdev_id
touch /etc/vdev_id.conf

if [ -f /usr/lib/udev/rules.d/69-vdev.rules ] && [ -x /usr/lib/udev/vdev_id ] && [ -f /etc/vdev_id.conf ];then
	echo "Installation Successful"
	echo "Configure alias with dmap/hmap"
else
	echo "Installation failed, double check network connection. Internet Access required"
fi
	
