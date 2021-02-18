#!/usr/bin/bash
mkdir 45drives-tools_1.8.2-1
git clone --branch 1.8.2 https://github.com/45Drives/tools.git
cp -R tools/src/fakeroot/* 45drives-tools_1.8.2-1
cp -r tools/deb/DEBIAN 45drives-tools_1.8.2-1/DEBIAN
rm -rf tools
dpkg-deb --build 45drives-tools_1.8.2-1
