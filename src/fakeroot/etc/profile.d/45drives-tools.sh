#!/bin/bash
command -v zfs >/dev/null
zfs_installed=$?
if [[ $zfs_installed -eq 0 ]]; then
        unset ALIAS_DEVICE_PATH
        unset ALIAS_CONFIG_PATH
        export ALIAS_DEVICE_PATH="/dev/disk/by-vdev"
        export ALIAS_CONFIG_PATH="/etc/zfs"
else
        unset ALIAS_DEVICE_PATH
        unset ALIAS_CONFIG_PATH
        export ALIAS_DEVICE_PATH="/dev"
        export ALIAS_CONFIG_PATH="/etc"
fi

alias lshealth="echo lshealth is deprecated. Using \'lsdev -H\'; lsdev -H"
alias lsmodel="echo lsmodel is deprecated. Using \'lsdev -m\'; lsdev -m"
alias lsosd="echo lsosd is deprecated. Using \'lsdev -o\'; lsdev -o"
alias lstype="echo lstype is deprecated. Using \'lsdev -t\'; lsdev -t"
