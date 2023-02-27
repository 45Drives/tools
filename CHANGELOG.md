## 45drives-tools 2.2.0-4

* dmap can now alias hardware RAID cards (9316-16i and 9361-24i)
* dmap will prompt user to put hardware cards in jbod mode with warning and perform necessary storcli64 commands
* server_identifier will now capture firmware version from HBA cards when run
* lsdev will display firmware version of connected storage controller cards
* added storcli2 binary to /opt/45drives/tools for 9600 series cards
* updated the device addressing scheme for 9600-16i HBA cards