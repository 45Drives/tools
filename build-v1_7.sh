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
git clone https://github.com/45Drives/tools.git
mkdir 45drives-tools-1.7
cp -r tools/etc 45drives-tools-1.7/etc
cp -r tools/opt 45drives-tools-1.7/opt
tar -zcvf 45drives-tools-1.7.tar.gz 45drives-tools-1.7/
rm -rf 45drives-tools-1.7
mv 45drives-tools-1.7.tar.gz rpmbuild/SOURCES/45drives-tools-1.7.tar.gz
mv tools/tools.spec rpmbuild/SPECS/tools.spec
rm -rf tools
rm -rf ~/rpmbuild
cd ..
cp -r 45drives-temp/rpmbuild ~/rpmbuild
rm -rf 45drives-temp
cd ~/rpmbuild
rpmbuild -ba SPECS/tools.spec