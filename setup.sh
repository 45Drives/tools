#!/bin/bash
mkdir -p /opt/ctools
ln -s $(pwd)/* /opt/ctools/
echo "export ALIAS_DEVICE_PATH=/dev" >> /root/.bashrc
echo "export ALIAS_CONFIG_PATH=/etc" >> /root/.bashrc
source /root/.bashrc
