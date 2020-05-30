
# 45Drives Server CLI Tools
### Supported OS
  - CentOS 7.X
  - CentOS 8.X
### Contents
  - Drive Aliasing
    - dmap : Configure device alias for Storinator all HDD and all SSD  chassis. (15,30,32,45,60)
    - hmap : Configure device alias for Storinator Hybrid chassis. (H16,H32)
    - alias_setup.sh : Configure udev rules for device alias'. Only needed when not using ZFS
    - profile.d/tools.sh : /etc/profile.d script to set enviroment varibles for device aliasing
    - map* : Called by dmap and hmap exclusively. Do not run these by themselves
  - Drive Display 
    - lsdev : List devices by their alias and standard linux block name. Detailed device info when "--json" flag used
    - lsmodel : List devices by their alias and model number
    - lstype : List devices by their alias and device type (hdd or ssd). For HDD reports rotational speed
  - ZFS Drive Tools
    - zcreate : Automatically creates zpools based on system hardware. Also takes input for fine tuned options, use '-h' flag for more options   
  - Ceph Drive Tools
    - lsosd : List devices by their alias and osd id (Node must be member of Ceph Cluster)
    - findosd : Takes osd id as input and outputs device alias. If osd is located on another host output is that hostname
    - generate-osd-vars.sh : Outputs list of devive names and device alias to stdout. Used by ceph-ansible playbook to autogenerate devices varibles
  
### Installation
CentOS 7.X
```sh
$ yum install URL
```
CentOS 8.X
```sh
$ dnf install URL
```
Install from git repo...

```sh
$ cd /opt
$ git clone https://github.com/45Drives/tools.git
$ #Install dependancies
$ yum install ipmitool jq smartmontools dmidecode pciutils
```
### RPM BUILD
Assuming rpmbuild enviroment set up already
```sh
$ cd ~/rpmbuild/SOURCES/
$ curl -LO https://github.com/45Drives/tools/archive/v1.X.tar.gz
$ tar -zxvf v1.X.tar.gz
$ mv tools-1.X 45drives-tools-1.X/
$ cp 45drives-tools-1.X/tools.spec SPECS/tools.spec
$ tar -zcvf 45drives-tools-1.X.tar.gz 45drives-tools-1.X/
$ cd ~/rpmbuild
$ rpmbuild -ba SPECS/tools.spec
```
