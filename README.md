
# 45Drives Server CLI Tools
### Supported OS
  - CentOS 7.X
  - Ubuntu 20.04.1 (45drives-tools version >= 1.8.3)

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
  
# Installation

## CentOS 7

### Add the 45drives-centos.repo
```
cd /etc/yum.repos.d
curl -LO http://images.45drives.com/repo/centos/45drives-centos.repo 
yum clean all
```

### 45drives-centos.repo
```
[45drives_stable]
baseurl = http://images.45drives.com/repo/centos/el$releasever/stable
enabled = 1
gpgcheck = 1
repo_gpgcheck = 1
gpgkey = http://images.45drives.com/repo/keys/rpmpubkey.asc
name = 45Drives Stable Packages
priority = 1

[45drives_testing]
baseurl = http://images.45drives.com/repo/centos/el$releasever/testing
enabled = 0
gpgcheck = 1
repo_gpgcheck = 1
gpgkey = http://images.45drives.com/repo/keys/rpmpubkey.asc
name = 45Drives Testing Packages
priority = 1

```

### Enable the 45drives_testing repo (*optional*)
The **latest versions** of our packages are available in our **45drives_testing** repo.  
By default, the 45drives_testing packages are **not** enabled.  

You can enable them by editing ```/etc/yum.repos.d/45drives-centos.repo``` with a text editor (nano, vim, etc ).  
Simply change ```enabled = 0``` to ```enabled = 1```.  

### Install Package
With the 45drives Repo enabled, you can now install using yum from your terminal.
```
yum install 45drives-tools
```

## Ubuntu 20

### Import 45drives repo GPG
```
wget -qO - http://images.45drives.com/repo/keys/aptpubkey.asc | apt-key add -
```

### Add the 45drives.list
```
cd /etc/apt/sources.list.d
sudo curl -LO http://images.45drives.com/repo/debian/45drives.list
sudo apt update
```

### 45drives.list
```
deb http://images.45drives.com/repo/debian focal main
#deb http://images.45drives.com/repo/debian focal-testing main

```

### Enable the 45drives_testing packages (*optional*)
The **latest versions** of our packages are available in our **45drives_testing** repo.  
By default, the 45drives_testing packages are **not** enabled.  

You can enable them by editing ```/etc/apt/sources.list.d/45drives.list``` with a text editor (nano, vim, etc ).  
You can uncomment (delete the **#** character) the second line.

### Install Package
```
sudo apt install 45drives-tools
```
