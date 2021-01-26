mkdir 45drives-tools_1.7.5-1
git clone --branch 1.7.5 https://github.com/45Drives/tools.git
cp -r tools/src/fakeroot/etc 45drives-tools_1.7.5-1/etc
cp -r tools/src/fakeroot/opt 45drives-tools_1.7.5-1/opt
cp tools/deb/makefile 45drives-tools_1.7.5-1/makefile
cd 45drives-tools_1.7.5-1
dh_make -p 45drives-tools_1.7.5-1 --single --native --copyright gpl3 -y
rm -f debian/{*.ex,*.EX,README.*}
cd ..
mv tools/deb/debian/rules 45drives-tools_1.7.5-1/debian/rules
mv tools/deb/debian/control 45drives-tools_1.7.5-1/debian/control
mv tools/deb/debian/copyright 45drives-tools_1.7.5-1/debian/copyright
mv tools/deb/debian/changelog 45drives-tools_1.7.5-1/debian/changelog
mv tools/deb/debian/45drives-tools-docs.docs 45drives-tools_1.7.5-1/debian/45drives-tools-docs.docs
rm -rf tools
