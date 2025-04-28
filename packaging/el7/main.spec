%global debug_package %{nil}
%define _build_id_links none

Name: ::package_name::
Version: ::package_version::
Release: ::package_build_version::%{?dist}
Summary: ::package_description_short::
License: ::package_licence::
URL: ::package_url::
Source0: %{name}-%{version}.tar.gz
BuildArch: ::package_architecture_el::
Requires: ::package_dependencies_el::

BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root

Provides:	%{name} = %{version}-%{release}
Conflicts:	%{name}-1.7

%description
::package_title::
::package_description_long::

%prep
%setup -q

%build

%install
make DESTDIR=%{buildroot} TOOLS_VERSION="%{version}-::package_build_version::" install

%postun
if [ $1 == 0 ];then
    rm -rf /opt/45drives/tools
    rm -rf /etc/45drives/server_info
	rm -f /usr/bin/cephfs-dir-stats
	rm -f /usr/bin/dmap
	rm -f /usr/bin/findosd
	rm -f /usr/bin/lsdev
	rm -f /usr/bin/server_identifier
	rm -f /usr/bin/zcreate
    rmdir /etc/45drives --ignore-fail-on-non-empty
    rmdir /opt/45drives --ignore-fail-on-non-empty
    OLD_TOOLS_DIR=/opt/tools
    if [ -d "$OLD_TOOLS_DIR" ]; then
        rm -rf "$OLD_TOOLS_DIR"
    fi
fi

%files
%dir /opt/45drives/tools
%dir /opt/45drives/ubm
%dir /etc/45drives/server_info
%defattr(-,root,root,-)
/etc/45drives/server_info/*
/opt/45drives/tools/*
/opt/45drives/ubm/*
%{_bindir}/*
/usr/lib/udev/rules.d/*

%changelog
* Thu Mar 13 2025 Brett Kelly <bkelly@45drives.com> 4.0.7-1
- add Stornado F16 support
* Tue Mar 04 2025 Brett Kelly <bkelly@45drives.com> 4.0.6-1
- add VM4 to lsdev
* Mon Mar 03 2025 Joshua Boudreau <jboudreau@45drives.com> 4.0.5-1
- include hostname in dump_info archive name
* Mon Mar 03 2025 Joshua Boudreau <jboudreau@45drives.com> 4.0.4-1
- add houston and snapshield info to dump_info
* Thu Feb 27 2025 Joshua Boudreau <jboudreau@45drives.com> 4.0.3-1
- dump_info: add storcli64 cmd and remove ceph mon_status
* Thu Feb 27 2025 Joshua Boudreau <jboudreau@45drives.com> 4.0.2-1
- Add dump_info command for gathering system diagnostic information
* Wed Feb 12 2025 Joshua Boudreau <jboudreau@45drives.com> 4.0.1-1
- Fix slot_speeds for PROXINATOR-VM8
* Fri Feb 07 2025 Brett Kelly <bkelly@45drives.com> 4.0.0-1
- jumping to 4.0 as we release for el9 and jammy
* Wed Feb 05 2025 Jordan Keough <jkeough@45drives.com> 3.0.18-1
- Updates lsdev to use binary size units instead of decimal
* Tue Feb 04 2025 Brett Kelly <bkelly@45drives.com> 3.0.17-1
- added support for Proxinator-VM4-15mm
* Wed Jan 22 2025 Brett Kelly <bkelly@45drives.com> 3.0.16-1
- added support for VM8-15mm products
* Wed Jan 15 2025 Brett Kelly <bkelly@45drives.com> 3.0.15-2
- adds mapping for Mi4 + Gigabyte MS03-6L0
- adds dmap support for vm8,16,32 in F2stornado
- added tools for automated zfs scrubs
* Tue Jan 07 2025 Brett Kelly <bkelly@45drives.com> 3.0.15-1
- reverse mapping order pro4/pro8
* Mon Dec 16 2024 Jordan Keough <jkeough@45drives.com> 3.0.14-1
- Adds support for HL4/8 and 45Professional
- Fixes sata addressing for HL4/8
* Wed Dec 04 2024 Jordan Keough <jkeough@45drives.com> 3.0.13-2
- Adds support for HL4/8 and 45Professional
* Wed Nov 20 2024 Jordan Keough <jkeough@45drives.com> 3.0.13-1
- Adds support for HL4/8 into dmap and dalias configs
* Fri Oct 18 2024 Brett Kelly <bkelly@45drives.com> 3.0.12-2
- adds support for hl4 and hl8
* Fri Oct 18 2024 Brett Kelly <bkelly@45drives.com> 3.0.12-1
- adds support for homelab hl4 & 8 units
* Wed Oct 16 2024 Jordan Keough <jkeough@45drives.com> 3.0.11-1
- Adds Gigabyte motherboards, Compute Node + 1U Gateway
* Thu Aug 22 2024 Brett Kelly <bkelly@45drives.com> 3.0.10-1
- adjusted logic when sorting cards to sort by controller id rather than bus address
* Thu Aug 22 2024 Brett Kelly <bkelly@45drives.com> 3.10.0-1
- adjusted logic when sorting cards to sort by controller id rather than bus address
* Tue Jul 23 2024 Brett Kelly <bkelly@45drives.com> 3.0.9-2
- added support for gigabyte motherboards
- added check for valid json from smartctl
* Tue Jul 23 2024 Brett Kelly <bkelly@45drives.com> 3.0.9-1
- added support for gigabyte motherboards
* Tue Jul 23 2024 Brett Kelly <bkelly@45drives.com> 3.09-1
- added support for gigabyte motherboards
* Tue Apr 16 2024 Brett Kelly <bkelly@45drives.com> 3.0.8-2
- added support for VM8,16,32 in lsdev and server_identifier
* Thu Mar 21 2024 Joshua Boudreau <jboudreau@45drives.com> 3.0.8-1
- Add support for Proxinator VM8, VM16, and VM32
* Wed Jan 31 2024 Brett Kelly <bkelly@45drives.com> 3.0.7-3
- Updated dmap to support MI4 Aliasing on H11 and H12 Motherboards
* Fri Jan 05 2024 Joshua Boudreau <jboudreau@45drives.com> 3.0.7-2
- fix symlink paths for ubm_func_wrapper.sh
* Fri Jan 05 2024 Mark Hooper <mhooper@45drives.com> 3.0.7-1
- Added features required for Stornado F2 server release
* Wed Jan 03 2024 Mark Hooper <mhooper@45drives.com> 3.0.6-5
- changed order in which /var/cache/45drives/ubm is removed. Rules will trigger after
  removal (for re-generation)
* Wed Jan 03 2024 Joshua Boudreau <jboudreau@45drives.com> 3.0.6-4
- fix getting ubm map key (strip whitespace)
* Tue Jan 02 2024 Joshua Boudreau <jboudreau@45drives.com> 3.0.6-3
- fix installation of ubm_func_wrapper tools
* Tue Jan 02 2024 Mark Hooper <mhooper@45drives.com> 3.0.6-2
- updated dmap to femove ubm map key directory to mitigate potential auto-aliasing
  issues
* Mon Dec 18 2023 Joshua Boudreau <jboudreau@45drives.com> 3.0.6-1
- add model, fw rev, state, status to slot_speeds output
* Fri Dec 08 2023 Joshua Boudreau <jboudreau@45drives.com> 3.0.5-1
- Add more ubm helper functions/tools
* Fri Dec 08 2023 Joshua Boudreau <jboudreau@45drives.com> 3.0.4-1
- Overhaul bash scripts for UBM
* Thu Dec 07 2023 Joshua Boudreau <jboudreau@45drives.com> 3.0.3-2
- bump build
* Thu Dec 07 2023 Joshua Boudreau <jboudreau@45drives.com> 3.0.3-1
- add slot_speeds script
* Tue Nov 21 2023 Mark Hooper <mhooper@45drives.com> 3.0.2-1
- added support for Stornado F2 device aliasing via use of udev rules
- dalias program added to provide means of custom device aliasing
- Homelab-HL15 server support added to lsdev
- releasing to stable repo
* Thu Nov 16 2023 Mark Hooper <mhooper@45drives.com> 3.0.1-3
- changed all instances of 2UTM to F2 for new Stornado server
* Fri Oct 06 2023 Mark Hooper <mhooper@45drives.com> 3.0.1-2
- added another field in loadtest script to check for hard drive model
* Wed Oct 04 2023 Mark Hooper <mhooper@45drives.com> 3.0.1-1
- lsdev and server_identifier have been updated to hangle HL15 servers
- added drive mapping for MI4 units using H12SSL-i and X11SPi-TF motherboards
* Tue Sep 05 2023 Joshua Boudreau <jboudreau@45drives.com> 3.0.0-9
- fix UBM_MAP_KEY caching in id_disk and on_enclosure_add
* Thu Aug 24 2023 Mark Hooper <mhooper@45drives.com> 3.0.0-8
- updated loadtest script to add disk model information in the log file.
* Tue Aug 22 2023 Joshua Boudreau <jboudreau@45drives.com> 3.0.0-7
- Print message to stderr when using storcli2 to get SLOT_NUM
* Tue Aug 22 2023 Joshua Boudreau <jboudreau@45drives.com> 3.0.0-6
- Fixed id_disk for case where controller has no drives
- Fixed udev rule to grab slot attr from parent of scsi block dev
* Tue Aug 22 2023 Mark Hooper <mhooper@45drives.com> 3.0.0-5
- updated server_identifier to identify and handle 9660-16i hardware raid cards
* Wed Aug 09 2023 Joshua Boudreau <jboudreau@45drives.com> 3.0.0-4
- change mpi3mr dependency to mpi3mr-dkms
* Thu Aug 03 2023 Mark Hooper <mhooper@45drives.com> 3.0.0-3
- updated Makefile
* Thu Aug 03 2023 Mark Hooper <mhooper@45drives.com> 3.0.0-2
- added dalias program for manual device aliasing
* Wed Aug 02 2023 Mark Hooper <mhooper@45drives.com> 3.0.0-1
- test build of tools which supports ubm backplanes
* Fri Jun 23 2023 Mark Hooper <mhooper@45drives.com> 2.2.3-1
- updated server_identifier and lsdev to operate with ceph gateway servers more gracefully
* Fri Jun 23 2023 Mark Hooper <mhooper@45drives.com> 2.2.2-8
- added contingency in server_identifier for 2U Gateway servers
* Tue Jun 13 2023 Mark Hooper <mhooper@45drives.com> 2.2.2-7
- added a check in server_identifier to ensure that the bus address of a given HBA
  matches that found in /sys/bus/pci/devices
* Mon Jun 12 2023 Mark Hooper <mhooper@45drives.com> 2.2.2-6
- added rudimentary bus address translation for ROMED8-2T Motherboards
* Tue May 23 2023 Mark Hooper <mhooper@45drives.com> 2.2.2-5
- added new lines to entries when alaising mi4 using ROMED8-2T
* Tue May 23 2023 Mark Hooper <mhooper@45drives.com> 2.2.2-4
- added support for MI4 servers that use ASRockRack ROME8-2T motherboards
* Wed Apr 26 2023 Mark Hooper <mhooper@45drives.com> 2.2.2-3
- Implemented fix for determining server model based on installed hardware for units
  serialized before 45Drives-tools package existed
* Fri Mar 31 2023 Mark Hooper <mhooper@45drives.com> 2.2.2-2
- Handled error when storcli64 is unable to report firmware version in server_identifier
* Tue Mar 21 2023 Mark Hooper <mhooper@45drives.com> 2.2.2-1
- Added a loadtest script for performing reads/writes to all storage drives simultaneously
* Fri Mar 17 2023 Mark Hooper <mhooper@45drives.com> 2.2.1-4
- modified loadtest script to output final result to log file
* Mon Mar 13 2023 Mark Hooper <mhooper@45drives.com> 2.2.1-3
- user can specify location of loadtest logfile using -l option
* Mon Mar 13 2023 Mark Hooper <mhooper@45drives.com> 2.2.1-2
- modified loadtest to work without requiring an hba card
* Fri Mar 10 2023 Mark Hooper <mhooper@45drives.com> 2.2.1-1
- Made a loadtest script for performing read/write operations on all storage drives
  simultaneously.
- added an lsscsi dependency required for loadtest script
- updated manifest for testing package
* Wed Mar 08 2023 Mark Hooper <mhooper@45drives.com> 2.2.0-7
- hotfix for H11SSL-i motherboards in MI4 units
* Wed Mar 08 2023 Mark Hooper <mhooper@45drives.com> 2.2.0-6
- Added a hotfix to alias MI4 servers using H11SSL-i motherboards
* Wed Mar 08 2023 Mark Hooper <mhooper@45drives.com> 2.2.0-5
- Added a hotfix to alias MI4 servers using H11SSL-i motherboards
* Mon Feb 27 2023 Mark Hooper <mhooper@45drives.com> 2.2.0-4
- dmap can now alias hardware RAID cards (9316-16i and 9361-24i)
- dmap will prompt user to put hardware cards in jbod mode with warning and perform
  necessary storcli64 commands
- server_identifier will now capture firmware version from HBA cards when run
- lsdev will display firmware version of connected storage controller cards
- added storcli2 binary to /opt/45drives/tools for 9600 series cards
- updated the device addressing scheme for 9600-16i HBA cards
* Thu Feb 16 2023 Mark Hooper <mhooper@45drives.com> 2.2.0-3
- updated physical order for 9600-16i HBA cards
* Thu Feb 16 2023 Mark Hooper <mhooper@45drives.com> 2.2.0-2
- added storcli2 binary to tools directory
* Wed Feb 15 2023 Mark Hooper <mhooper@45drives.com> 2.2.0-1
- dmap can now alias hardware RAID cards (9316-16i and 9361-24i)
- dmap will prompt user to put hardware cards in jbod mode with warning and perform
  necessary storcli64 commands
- server_identifier will now capture firmware version from HBA cards when run
- lsdev will display firmware version
* Thu Feb 02 2023 Mark Hooper <mhooper@45drives.com> 2.1.2-1
- Added support for F8X line of Storinators
* Wed Jan 04 2023 Mark Hooper <mhooper@45drives.com> 2.1.1-1
- updated how F8X servers are aliased in dmap
* Mon Oct 31 2022 Mark Hooper <mhooper@45drives.com> 2.1.0-4
- added support for 9400-16i HBA cards
* Wed Sep 14 2022 Mark Hooper <mhooper@45drives.com> 2.1.0-3
- Added support for F8X servers (naming convention subject to change)
- Updated server_identifier script to work with ASRockRack EPC621D8A motherboards
* Tue Aug 23 2022 Mark Hooper <mhooper@45drives.com> 2.1.0-2
- updated check for motherboard serial number in server_identifier
* Tue Aug 23 2022 Mark Hooper <mhooper@45drives.com> 2.1.0-1
- Added support for ASRockRack EPC621D8A motherboards
- added support for F8X prototype server device aliasing
- updated how hba cards are detected to work with ASRockRack motherboards
- improved/added new error messages for dmap, lsdev and server_identifier
* Mon Aug 08 2022 Mark Hooper <mhooper@45drives.com> 2.0.8-10
- added device aliasing for AV15-H16 server models
* Mon Jul 25 2022 Mark Hooper <mhooper@45drives.com> 2.0.8-9
- hotfix for AV15-H16 Servers
* Wed Jul 06 2022 Mark Hooper <mhooper@45drives.com> 2.0.8-6
- released to 45drives stable repo
- added support for 9600 series HBA cards
- lspci is used over storcli64 to determine HBA card model (9305-16i vs 9305-24i
  for example)
- added the mpi3mr dependency for ubuntu, as this driver is not built into the kernel
- 45drives-tools > 2.0.8 is no longer supported for centos7 and ubuntu-bionic
* Thu Jun 30 2022 Mark Hooper <mhooper@45drives.com> 2.0.8-5
- updated pci.ids file to report 9405W-16i cards accurately
- updated the hba adapter reported in server_identifier for 9405W-16i cards
* Wed Jun 29 2022 Mark Hooper <mhooper@45drives.com> 2.0.8-4
- updated postrm script
* Wed Jun 29 2022 Mark Hooper <mhooper@45drives.com> 2.0.8-3
- added /opt/45drives/tools/pci.ids file for use by lspci when detecting HBA cards
* Fri Jun 24 2022 Mark Hooper <mhooper@45drives.com> 2.0.8-2
- modified how hba cards are detected using lspci
* Thu Jun 23 2022 Mark Hooper <mhooper@45drives.com> 2.0.8-1
- added support for 9600-24i and 9600-16i hba cards
* Tue May 17 2022 Mark Hooper <mhooper@45drives.com> 2.0.7-1
- updated virtual machine behavior for server_identifier
* Wed May 04 2022 Mark Hooper <mhooper@45drives.com> 2.0.6-5
- updated how bus addresses for hba cards are handled in server_identifier
- added support for H12 motherboards
* Thu Apr 28 2022 Mark Hooper <mhooper@45drives.com> 2.0.6-4
- added support for Destroyinator servers in dmap, server_identifier and lsdev
* Mon Apr 04 2022 Mark Hooper <mhooper@45drives.com> 2.0.6-3
- dmap will find and replace the udev rules path in 68-vdev.rules.
- lsdev will tell user to run as root when invoking smartctl.
- updated the smartctl timeout values in lsdev.
* Wed Feb 23 2022 Mark Hooper <mhooper@45drives.com> 2.0.6-2
- added support for Destroyinator servers in dmap, server_identifier and lsdev
* Wed Feb 16 2022 Mark Hooper <mhooper@45drives.com> 2.0.6-1
- added support for 2U Stornado
* Mon Jan 24 2022 Mark Hooper <mhooper@45drives.com> 2.0.5-4
- bugfix for missing smart_status key in lsdev
* Thu Jan 13 2022 Mark Hooper <mhooper@45drives.com> 2.0.5-3
- bugfix for lsdev when invoking smartctl
* Fri Nov 26 2021 Mark Hooper <mhooper@45drives.com> 2.0.5-2
- added -d command line argument to generate-osd-vars.sh
* Wed Nov 24 2021 Joshua Boudreau <jboudreau@45drives.com> 2.0.5-1
- Fixed bug in wipedev where `wipedev -a` skipped slot 1-1
* Wed Nov 10 2021 Mark Hooper <mhooper@45drives.com> 2.0.4-3
- updated server_identifier to store the controller id of hba cards
- updated lsdev to be able to read temperatures from SAS drives using smartctl
* Wed Oct 13 2021 Mark Hooper <mhooper@45drives.com> 2.0.4-2
- updated server_identifier to ensure that bus addresses for HBA cards provided by
  dmidecode are present in /sys/bus/pci/devices
* Thu Oct 07 2021 Mark Hooper <mhooper@45drives.com> 2.0.4-1
- simplified generate-osd-vars.sh to be hardware agnostic
* Fri Sep 10 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-12
- removed systemd-udev dependency
* Fri Sep 10 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-11
- fixed typo in dmap udev path from last patch
* Wed Sep 08 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-10
- added packaging for Ubuntu bionic
* Wed Sep 08 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-9
- removed the preinst script for bionic and reverted postrm
* Wed Sep 08 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-8
- pushing an update to auto build
* Wed Sep 08 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-7
- adding preferences file to bionic install
* Wed Sep 08 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-6
- trying to get specific dependency for smartmontools
* Wed Sep 08 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-5
- added dep smartmontools (7.0-0ubuntu1~ubuntu18.04.1)
* Wed Sep 08 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-4
- changed format of Depends in bionic control file
* Wed Sep 08 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-3
- updated bionic dependencies to require smartmontools from bionic-backports
* Tue Sep 07 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-2
- updated dmap to look to rules files in /bin/udev if /usr/bin/udev is not found
- added udev as a dependency
- removed hard path of /usr/bin/cp from dmap
* Tue Sep 07 2021 Mark Hooper <mhooper@45drives.com> 2.0.3-1
- created a package for 45drives-tools for Ubuntu (bionic)
* Tue Sep 07 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-13
- exported DEB_BUILD_OPTIONS to append nostrip
* Tue Sep 07 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-12
- override dh_dwz make target
* Tue Sep 07 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-11
- third build for Ubuntu Bionic
* Tue Sep 07 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-10
- second build for Ubuntu bionic
* Tue Sep 07 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-9
- added autopackaging for Ubuntu bionic
* Fri Aug 27 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-8
- added disk type to json output
* Fri Aug 27 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-7
- added -c option to lsdev for displaying drive capacity
* Wed Aug 25 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-6
- removed build id links in .spec files
* Fri Aug 20 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-5
- Modified --json option in lsdev
* Thu Aug 19 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-4
- updated el8 package signature
* Thu Aug 19 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-3
- updated el8 package signature
* Thu Aug 19 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-2
- added new product keys for Bronze, Silver and Gold Intel CPUs using X11SPL-F Motherboards
* Thu Aug 05 2021 Mark Hooper <mhooper@45drives.com> 2.0.2-1
- added signed el7 packaging and put this version on 45drives-stable
* Thu Aug 05 2021 Mark Hooper <mhooper@45drives.com> 2.0.1-3
- testing el7 gpg signing
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.1-2
- added el7 packaging
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.1-1
- made deb and rpm tools_version file congruent
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-14
- checking output of sed command
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-13
- checking output of sed command
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-12
- checking output of sed command
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-11
- checking output of sed command
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-10
- modified sed command in rules
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-9
- set postrm script to use bash (focal)
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-8
- modified search for tools version in rules file (focal)
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-7
- fixed indentation in dmap
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-6
- added ignore debug flag in spec file
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-5
- changed architecture and spec file
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-4
- updated makefile
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-3
- updated makefile
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-2
- updated makefile
* Thu Jul 29 2021 Mark Hooper <mhooper@45drives.com> 2.0.0-1
- configured autopackaging for 45drives-tools on rocky and ubuntu
- updated uninstall process to remove all files associated with 45drives-tools
- updated makefile
- dmap outputs full version in vdev_id.conf