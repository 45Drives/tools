
# 45Drives Server CLI Tools
### Supported OS
  - CentOS 7.X
  - CentOS 8.X

### Contents
  - Drive Aliasing
    - dmap: (opt/tools/dmap)
      ```
      Automatically configures device aliases for 45Drives Storinator products.
      Options:
        -h, --help        show this help message and exit
        -m, --no-udev     Creates map but doesnt trigger udev rules
        -s SZ, --size=SZ  Specify chassis size
        -q, --quiet       Quiet Mode
        -r, --reset-map   Resets the drive map
      ```
    - profile.d/tools.sh: (/etc/profile.d/tools.sh)
        ```
        A script that automatically runs at login. 
        Sets enviroment varibles required for device aliasing.
        ```
  - Drive Display
    - lsdev: (opt/tools/lsdev)
      ```
      Lists a variety of block device information. 
        Options:
          -h, --help                    show this help message and exit
          -j, --json                    Output in JSON format
          -n, --no-color, --no-colour   Replace colour coding with asterisks
          -d, --device                  Output device name "/dev/sd<x>/"
          -H, --health                  Output SMARTCTL health (slow)
          -m, --model                   Output model names
          -t, --type                    Output drive types (HDD/SSD)
          -s, --serial                  Output serial numbers
          -T, --temp                    Output temperature (deg-C) (slow)
          -f, --firmware                Output firmware version
          -o, --ceph-osd                Output OSD name - Ceph only
        ```
  - ZFS Drive Tools
    - zcreate: (/opt/tools/zcreate)
      ```
      Automatically creates zpools based on system hardware. 
      Also takes input for fine tuned options. 
      Use '-h' flag for more options
      ```   
  - Ceph Drive Tools
    - findosd: (/opt/tools/findosd)
      ```
      Takes osd id as input and outputs device alias. 
      If osd is located on another host output is that hostname.
      ```
    - generate-osd-vars.sh: (opt/tools/generate-osd-vars.sh) 
      ```
      Outputs list of devive names and device alias to stdout. 
      Used by ceph-ansible playbook to autogenerate devices varibles
      ```
    - wipedev (/opt/tools/wipedev)
      ```
      Wipes the partition table of all drives in system. 
      (excluding server's OS drives).
      ```
  - Polkit rules for use with Cockpit
  
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
$ yum install ipmitool jq smartmontools dmidecode pciutils python3
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
