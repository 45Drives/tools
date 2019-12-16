#!/bin/bash

VDEV_RULES="http://images.45drives.com/ceph/udev/69-vdev.rules"
VDEV_ID="http://images.45drives.com/ceph/udev/vdev_id"

if rpm -q zfs >/dev/null 2>&1;then
	echo "ZFS is installed quiting"
	echo "This will overwrite ZFS udev rules"
fi

curl -o /usr/lib/udev/rules.d/69-vdev.rules $VDEV_RULES
curl -o /usr/lib/udev/vdev_id $VDEV_ID > /dev/null ; chmod +x /usr/lib/udev/vdev_id
touch /etc/vdev_id.conf

if [ -f /usr/lib/udev/rules.d/69-vdev.rules ] && [ -x /usr/lib/udev/vdev_id ] && [ -f /etc/vdev_id.conf ];then
	echo "Installation Successful"
	echo "Configure alias with dmap"
else
	echo "Installation failed, double check network connection. Internet Access required"
fi
	
