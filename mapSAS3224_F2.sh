#!/bin/bash
# ---------------------------------------------------------------------------
# mapSAS3224_F2 - Used by dmap to generate LSI HBA models using SAS chipset 3224 alias config

# Copyright 2016, Brett Kelly <bkelly@45drives.com> Mitch Hall <mhall@45drives.com>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

cat << EOF > /etc/vdev_id.conf

# by-vdev
# name     fully qualified or base name of device link
alias 1-1     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy9-lun-0
alias 1-2     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy11-lun-0
alias 1-3     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy13-lun-0
alias 1-4     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy15-lun-0
alias 1-5     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy8-lun-0
alias 1-6     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy10-lun-0
alias 1-7     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy12-lun-0
alias 1-8     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy14-lun-0
alias 1-9     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy1-lun-0
alias 1-10     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy3-lun-0
alias 1-11     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy5-lun-0
alias 1-12     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy7-lun-0
alias 1-13     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy0-lun-0
alias 1-14     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy2-lun-0
alias 1-15     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy4-lun-0
alias 1-16     /dev/disk/by-path/pci-0000:3b:00.0-sas-phy6-lun-0
alias 2-1     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy9-lun-0
alias 2-2     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy11-lun-0
alias 2-3     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy13-lun-0
alias 2-4     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy15-lun-0
alias 2-5     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy8-lun-0
alias 2-6     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy10-lun-0
alias 2-7     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy12-lun-0
alias 2-8     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy14-lun-0
alias 2-9     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy1-lun-0
alias 2-10     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy3-lun-0
alias 2-11     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy5-lun-0
alias 2-12     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy7-lun-0
alias 2-13     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy0-lun-0
alias 2-14     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy2-lun-0
alias 2-15     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy4-lun-0
alias 2-16     /dev/disk/by-path/pci-0000:d8:00.0-sas-phy6-lun-0
EOF
