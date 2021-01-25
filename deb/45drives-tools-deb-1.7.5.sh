mkdir 45drives-tools_1.7.5-1
git clone --branch 1.7.5 https://github.com/45Drives/tools.git
cp -r tools/src/fakeroot/etc 45drives-tools_1.7.5-1/etc
cp -r tools/src/fakeroot/opt 45drives-tools_1.7.5-1/opt
mkdir 45drives-tools_1.7.5-1/DEBIAN
mv tools/deb/control 45drives-tools_1.7.5-1/DEBIAN/control
rm -rf tools
