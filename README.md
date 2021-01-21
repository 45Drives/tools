
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
  
### Installation
CentOS 7.X
```sh
yum install http://images.45drives.com/stable/CentOS/el7/x86_64/45drives-tools-1.7.5-1.el7.x86_64.rpm
```
CentOS 8.X
```sh
dnf install http://images.45drives.com/ceph/rpm/el8/x86_64/45drives-tools-1.7-4.el8.x86_64.rpm
```

### RPM BUILD from git repo (requires "rpm-build" and "git" packages (centOS))
use the provided script (45drives-tools-rpm-1.7.5.sh)
```sh
# don't run this if you have a ~/rpmbuild folder that you don't want to lose! 
curl -O https://raw.githubusercontent.com/45Drives/tools/1.7.5/rpm/45drives-tools-rpm-1.7.5.sh
chmod +x 45drives-tools-rpm-1.7.5.sh
./45drives-tools-rpm-1.7.5.sh 
```