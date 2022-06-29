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
%dir /etc/45drives/server_info
%defattr(-,root,root,-)
/etc/45drives/server_info/*
/opt/45drives/tools/*
%{_bindir}/*

%changelog
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