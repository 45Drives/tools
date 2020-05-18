
# 45Drives Server CLI Tools
### Supported OS
  - CentOS 7.X
  - CentOS 8.X
### Contents
  - Drive Aliasing
    - dmap : Configure device alias for Storinator all HDD and all SSD  chassis. (15,30,32,45,60)
    - hmap : Configure device alias for Storinator Hybrid chassis. (H16,H32)
    - alias_setup.sh : Configure udev rules for device alias'. Only needed when not using ZFS.
    - profile.d/tools.sh : /etc/profile.d script to set enviroment varibles for device aliasing
    - map* : Called by dmap and hmap exclusively. Do not run these by themselves
  - Drive Display 
    - lsdev : List devices by their alias and standard linux block name
    - lsmodel : List devices by their alias and model number
    - lstype : List devices by their alias and device type (hdd or ssd). For HDD reports rotational speed
  - ZFS Drive Tools
    - zcreate : Creates zpools based on system hardware. Also takes input for fine tuned options, use '-h' flag for more options   
  - Ceph Drive Tools
    - lsosd : List devices by their alias and osd id (Node must be member of Ceph Cluster)
    - findosd : Takes osd id as input and outputs device alias. If osd is located on another host output is that hostname
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
$ mkdir /opt/tools
$ cd /opt/tools
$ git clone https://github.com/45Drives/tools.git
$ #Install dependancies
$ yum install DEPS
```

