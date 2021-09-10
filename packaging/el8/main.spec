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