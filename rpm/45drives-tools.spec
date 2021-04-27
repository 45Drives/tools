%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Name:		45drives-tools
Version:	1.9.1
Release:	2%{?dist}
Summary:	Server CLI Tools

Group:		Development/Tools
License:	GPL
URL:		https://github.com/45Drives/tools
Source0:	%{name}-%{version}.tar.gz

BuildArch:	x86_64
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root

Requires: ipmitool
Requires: jq
Requires: smartmontools > 7.0
Requires: dmidecode
Requires: python3
Requires: pciutils
Requires: hdparm


Provides:	%{name} = %{version}-%{release}
Conflicts:	%{name}-1.7

%description
45Drives server cli tools

%prep
%setup -q

%build
# empty

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}
mkdir -p %{buildroot}%{_bindir}

# in builddir
cp -a etc/ %{buildroot}
cp -a opt/ %{buildroot}
mkdir -p %{buildroot}/etc/45drives/server_info

pushd opt/45drives/tools/
    for i in lsdev dmap findosd zcreate cephfs-dir-stats server_identifier; do
        ln -sf /opt/45drives/tools/$i %{buildroot}%{_bindir}
    done
popd

%clean
rm -rf %{buildroot}

%files
%dir /opt/45drives/tools
%dir /etc/45drives/server_info
%defattr(-,root,root,-)
/etc/45drives/server_info/tools_version
/opt/45drives/tools/*
%{_bindir}/*



%changelog
* Tue Apr 27 2021 Mark Hooper <mhooper@45drives.com> 1.9.1-2
- Adjusted lsdev and dmap to handle Supermicro SSG-6048R-E1CR24H drive ailiasing.
- /etc/45drives/server_info/server_info.json must be manually edited to handle this style of ailiasing.
- modified version file and comment string in vdev_id.conf.
* Fri Apr 16 2021 Mark Hooper <mhooper@45drives.com> 1.9.0-2
- modified vdev_id.conf comment to reflect version 1.9.0-2.
* Fri Apr 16 2021 Mark Hooper <mhooper@45drives.com> 1.9.0-1
- updated the way in which AV15 Base drives 1-9 thru 1-15 are ailiased based on on-board sata wiring.
* Thu Apr 1 2021 Mark Hooper <mhooper@45drives.com> 1.8.10-1
- updated server_identifier to detect Storinator-H8 Models.
* Fri Mar 26 2021 Mark Hooper <mhooper@45drives.com> 1.8.9-1
- dmap will use 68-vdev.rules and vdev_id_45drives script for udev rules instead of those provided/named by zfs.
* Wed Mar 24 2021 Mark Hooper <mhooper@45drives.com> 1.8.8-1
- server_identifier now stores the OS NAME and OS VERSION_ID.
- dmap will append the ".0" for all ailias paths /dev/disk/by-path/... if server has CentOS 7 installed.
- dmap also will reload udev rules before triggering them.
- Updated the tools version file in /etc/45drives/server_info/tools_version to 1.8.8
* Mon Mar 22 2021 Brett Kelly <bkelly@45drives.com> 1.8.7-1
- Updated generate-osd-vars to support dedicated db in OSD
- Replaced open-cas check with a OS agnostic one
* Fri Mar 19 2021 Brett Kelly <bkelly@45drives.com> 1.8.7-1
- generate-osd-vars.sh now supports dedicated db devices for ceph clusters
* Mon Mar 8 2021 Mark Hooper <mhooper@45drives.com> 1.8.6-1
- tools_version file is now being created properly.
- updating version to 1.8.6 to rectify improper use of obsoletes statement. 
* Mon Mar 8 2021 Mark Hooper <mhooper@45drives.com> 1.8.5-4
- tools_version file is still not being created, removed the echo statement from spec file. 
* Mon Mar 8 2021 Mark Hooper <mhooper@45drives.com> 1.8.5-3
- Added /etc/45drives/server_info/* to the files directive in spec file. 
* Mon Mar 8 2021 Mark Hooper <mhooper@45drives.com> 1.8.5-2
- Updated the tools version file in /etc/45drives/server_info/tools_version to 1.8.5.
* Mon Mar 8 2021 Mark Hooper <mhooper@45drives.com> 1.8.5-1
- Added missing key-value pairs for server_identifier for Enhanced-AMD servers.
* Mon Mar 1 2021 Mark Hooper <mhooper@45drives.com> 1.8.4-2
- Added missing key-value pair to server_identifier for Storinator-XL60-Enhanced-AMD.
* Mon Mar 1 2021 Mark Hooper <mhooper@45drives.com> 1.8.4-1
- Added missing integer to XL60 array, causing dmap faults in non-autodetectable units.
* Thu Feb 25 2021 Mark Hooper <mhooper@45drives.com> 1.8.3-1
- added missing newline character to rules script.
- modified postrm behavior, as updating the package was deleting files required by new package. 
* Thu Jan 28 2021 Mark Hooper <mhooper@45drives.com> 1.8.2-1
- fixed bug in lsdev when it looks in /etc/zfs for vdev_id.conf, now always looks for /etc/vdev_id.conf.
- Added lsdev support for future Storinator M4 and C8 Models.
* Thu Jan 28 2021 Mark Hooper <mhooper@45drives.com> 1.8.1-1
- Modified dmap to automatically place required udev files (69-vdev.rules and vdev_id) in /usr/lib/udev.
- Removed /etc/profile.d/45drives-tools.sh as ALIAS_CONFIG_PATH and ALIAS_DEVICE_PATH are no longer needed.
- This will serve as the baseline for tools going forward to be compatible with Ubuntu and Centos7
* Thu Jan 28 2021 Mark Hooper <mhooper@45drives.com> 1.8.0-1
- removed problematic symlink (/opt/tools) -> (/opt/45drives/tools) causing migration issues.
- This will serve as the baseline for tools going forward to be compatible with Ubuntu and Centos7
* Wed Jan 27 2021 Mark Hooper <mhooper@45drives.com> 1.7.5-2
- added conflicts to spec file to ensure proper upgrade path.
* Thu Jan 21 2021 Mark Hooper <mhooper@45drives.com> 1.7.5-1
- Made changes to the directory structure of the script locations (/opt/tools/ -> /opt/45drives/tools).
- Updated the symbolic links to preserve backwards compatability for this directory change.
- Changed the location of the server_info.json file created by server_identifier (/etc/server_info/server_info.json -> /etc/45drives/server_info/server_info.json)
* Thu Jan 14 2021 Mark Hooper <mhooper@45drives.com> 1.7-4
- Addressed autodetect behavior for previous gen motherboards in server_identifier.
- Added verbose messages to address any inconsistencies encountered due to manual edits of /etc/server_info/server_info.json.
* Tue Jan 12 2021 Mark Hooper <mhooper@45drives.com> 1.7-3
- fixed ALIAS_DEVICE_PATH bug in /etc/profile.d/tools.sh
* Mon Jan 11 2021 Mark Hooper <mhooper@45drives.com> 1.7-2
- fixed bus address bug in dmap encountered with X11DPL-i motherboards.
- made adjustments to server_identifier script to deal with VMs and VMs with HBA passthroughs.
- added an "Edit Mode" flag in /etc/server_info/server_info.json to allow for manual edits to this file to be used in dmap.
* Wed Jan 6 2021 Mark Hooper <mhooper@45drives.com> 1.7
- added hmap functionality into dmap.
- updated lsdev to display drives based on their physical location within the server.
- created server_identifier script, which can identify the 45Drives product type and store that information in /etc/server_info/server_info.json.
* Tue Sep 1 2020 Mark Hooper <mhooper@45drives.com> 1.6
- second build 1.6, fixed zfs ailiasing bug
* Tue Sep 1 2020 Mark Hooper <mhooper@45drives.com> 1.5
- First build 1.5, added hdparm dependancy
* Sat May 30 2020 Brett Kelly <bkelly@45drives.com> 1.3
- Second build 1.3, added python dependancy 
* Sat May 30 2020 Brett Kelly <bkelly@45drives.com> 1.3
- First build 1.3, added generate-osd-vars.sh 
* Tue May 26 2020 Brett Kelly <bkelly@45drives.com> 1.2
- First build 1.2, added lsdev json output, smartctl attr 
* Mon May 18 2020 Brett Kelly <bkelly@45drives.com> 1.1
- Second build, link files from opt/tools to bin dir
* Mon May 18 2020 Brett Kelly <bkelly@45drives.com> 1.1
- First build of v1.1. Added zfs check in profile.d script. Organized code. Removed unneeded scripts
* Tue May 12 2020 Josh Boudreau <jboudreau@45drives.com> 1.0
- First build of v1.0

