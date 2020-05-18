if rpm -q zfs >/dev/null 2>&1;then
	export ALIAS_DEVICE_PATH=/dev/disk/by-vdev
	export ALIAS_CONFIG_PATH=/etc/zfs
else
        export ALIAS_DEVICE_PATH=/dev/
        export ALIAS_CONFIG_PATH=/etc/
fi
