%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Name:		45drives-tools
Version:	1.1
Release:	2%{?dist}
Summary:	Server CLI Tools

Group:		Development/Tools
License:	GPL
URL:		https://github.com/45Drives/tools
Source0:	%{name}-%{version}.tar.gz

BuildArch:	noarch
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root

Requires: ipmitool
Requires: jq
Requires: smartmontools > 7.0
Requires: dmidecode
Requires: pciutils

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

pushd opt/tools/
    for i in ls* *map findosd zcreate; do
        ln -sf /opt/tools/$i %{buildroot}%{_bindir}
    done
popd

%clean
rm -rf %{buildroot}

%files
%dir /opt/tools
%dir /etc/profile.d
%defattr(-,root,root,-)
/opt/tools/*
/etc/profile.d/tools.sh
%{_bindir}/*

%changelog
* Mon May 18 2020 Brett Kelly <bkelly@45drives.com> 1.1
- Second build, link files from opt/tools to bin dir
* Mon May 18 2020 Brett Kelly <bkelly@45drives.com> 1.1
- First build of v1.1. Added zfs check in profile.d script. Organized code. Removed unneeded scripts

