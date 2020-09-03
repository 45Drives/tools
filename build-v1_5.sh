mkdir rpmbuild rpmbuild/RPMS rpmbuild/SOURCES rpmbuild/SPECS rpmbuild/SRPMS rpmbuild/RPMS/noarch
git clone https://github.com/45Drives/tools.git
mkdir 45drives-tools-1.5
cp -r tools/etc 45drives-tools-1.5/etc
cp -r tools/opt 45drives-tools-1.5/opt
tar -zcvf 45drives-tools-1.5.tar.gz 45drives-tools-1.5/
rm -rf 45drives-tools-1.5
mv 45drives-tools-1.5.tar.gz rpmbuild/SOURCES/45drives-tools-1.5.tar.gz
mv tools/tools.spec rpmbuild/SPECS/tools.spec
rm -rf tools
cp -r rpmbuild ~/rpmbuild
rm -rf rpmbuild
cd ~/rpmbuild
rpmbuild -ba SPECS/tools.spec