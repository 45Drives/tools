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

read -p "Which Version? (eg 1.2.1): " ver

mkdir 45drives-temp
cd 45drives-temp
mkdir rpmbuild rpmbuild/RPMS rpmbuild/SOURCES rpmbuild/SPECS rpmbuild/SRPMS
git clone --branch dev https://github.com/45Drives/tools.git
cd tools
git checkout tags/$ver
checkout=$?
cd ..
if [ $checkout != 0 ]; then
	echo "version does not exist. Try a different version."
	cd ..
	rm -rf 45drives-temp
	exit 1
fi
mkdir 45drives-tools-$ver
cp -r tools/src/fakeroot/etc 45drives-tools-1.8.2/etc
cp -r tools/src/fakeroot/opt 45drives-tools-1.8.2/opt
tar -zcvf 45drives-tools-$ver.tar.gz 45drives-tools-$ver/
rm -rf 45drives-tools-$ver
mv 45drives-tools-$ver.tar.gz rpmbuild/SOURCES/45drives-tools-$ver.tar.gz
mv tools/rpm/45drives-tools.spec rpmbuild/SPECS/45drives-tools-$ver.spec
rm -rf tools
rm -rf ~/rpmbuild
cd ..
cp -r 45drives-temp/rpmbuild ~/rpmbuild
rm -rf 45drives-temp
cd ~/rpmbuild
rpmbuild -ba SPECS/45drives-tools-$ver.spec
