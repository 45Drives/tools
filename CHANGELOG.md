## 45drives-tools 2.0.8-6

* released to 45drives stable repo
* added support for 9600 series HBA cards
* lspci is used over storcli64 to determine HBA card model (9305-16i vs 9305-24i for example)
* added the mpi3mr dependency for ubuntu, as this driver is not built into the kernel
* 45drives-tools > 2.0.8 is no longer supported for centos7 and ubuntu-bionic