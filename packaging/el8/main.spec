%global debug_package %{nil}

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