# don't run this if you have a ~/rpmbuild folder that you don't want to lose! 
mkdir 45drives-temp
cd 45drives-temp
mkdir rpmbuild rpmbuild/RPMS rpmbuild/SOURCES rpmbuild/SPECS rpmbuild/SRPMS
git clone https://github.com/45Drives/tools.git
mkdir 45drives-tools-1.6
cp -r tools/etc 45drives-tools-1.6/etc
cp -r tools/opt 45drives-tools-1.6/opt
tar -zcvf 45drives-tools-1.5.tar.gz 45drives-tools-1.6/
rm -rf 45drives-tools-1.6
mv 45drives-tools-1.6.tar.gz rpmbuild/SOURCES/45drives-tools-1.6.tar.gz
mv tools/tools.spec rpmbuild/SPECS/tools.spec
rm -rf tools
rm -rf ~/rpmbuild
cd ..
cp -r 45drives-temp/rpmbuild ~/rpmbuild
rm -rf 45drives-temp
cd ~/rpmbuild
rpmbuild -ba SPECS/tools.spec