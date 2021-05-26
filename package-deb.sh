#!/usr/bin/env bash

UBUNTU_VERSION=$1

if [[ $UBUNTU_VERSION != "focal" ]] && [[ $UBUNTU_VERSION != "bionic" ]];then
	echo "version required, focal or bionic"
	echo "./package-deb.sh <focal|bionic>"
	exit 1
fi

# fill this in with a name unique to the software package
PACKAGE_NAME=45drives-tools

# check that docker is installed
command -v docker > /dev/null 2>&1 || {
	echo "Please install docker.";
	exit 1;
}

# if docker image DNE, build it (keep container tag name unique to software package)
if [[ "$(docker images -q $PACKAGE_NAME-ubuntu-builder-$UBUNTU_VERSION 2> /dev/null)" == "" ]]; then
	docker build -t $PACKAGE_NAME-ubuntu-builder-$UBUNTU_VERSION - < docker/ubuntu-$UBUNTU_VERSION # pass in path to docker file
	res=$?
	if [ $res -ne 0 ]; then
		echo "Building docker image failed."
		exit $res
	fi
fi

make clean

mkdir -p dist/ubuntu

# mirror current directory to working directory in container, and mirror dist/ubuntu to .. for deb output
docker run -u $(id -u):$(id -g) -w /home/deb/build -it -v$(pwd):/home/deb/build -v$(pwd)/dist/ubuntu:/home/deb --rm $PACKAGE_NAME-ubuntu-builder-$UBUNTU_VERSION dpkg-buildpackage -us -uc -b
res=$?
if [ $res -ne 0 ]; then
	echo "Packaging failed."
	exit $res
fi

rmdir dist/ubuntu/build

echo "deb is in dist/ubuntu/"

exit 0
