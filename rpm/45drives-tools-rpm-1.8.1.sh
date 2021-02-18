echo "Don't run this if you have a ~/rpmbuild folder that you don't want to lose!"
read -p "Are you sure you want to continue ? (yes/no) " con
case $con in
    yes)
        ;;
    *)
        echo "exiting..."
        exit 0
        ;;
esac


mkdir 45drives-temp
cd 45drives-temp
mkdir rpmbuild rpmbuild/RPMS rpmbuild/SOURCES rpmbuild/SPECS rpmbuild/SRPMS
git clone --branch 1.8.1 https://github.com/45Drives/tools.git
mkdir 45drives-tools-1.8.1
cp -r tools/src/fakeroot/etc 45drives-tools-1.8.1/etc
cp -r tools/src/fakeroot/opt 45drives-tools-1.8.1/opt
rm 45drives-tools-1.8.1/opt/tools
tar -zcvf 45drives-tools-1.8.1.tar.gz 45drives-tools-1.8.1/
rm -rf 45drives-tools-1.8.1
mv 45drives-tools-1.8.1.tar.gz rpmbuild/SOURCES/45drives-tools-1.8.1.tar.gz
mv tools/rpm/45drives-tools-1.8.1.spec rpmbuild/SPECS/45drives-tools-1.8.1.spec
rm -rf tools
rm -rf ~/rpmbuild
cd ..
cp -r 45drives-temp/rpmbuild ~/rpmbuild
rm -rf 45drives-temp
cd ~/rpmbuild
rpmbuild -ba SPECS/45drives-tools-1.8.1.spec
