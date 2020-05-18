%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Name:		tools
Version:	1.1
Release:	1%{?dist}
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

%description

45Drives server cli tools

%prep
%setup -q

%build
# empty

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}

# in builddir
for file in alias_setup.sh *map findosd ls* map* wipedev zcreate; do
    cp -a $f %{buildroot}
    ln -sf /opt/tools/* %{buildroot}%{_bindir} 
done

%clean
rm -rf %{buildroot}

%files
%dir /opt/tools
%dir /etc/profile.d
%defattr(-,root,root,-)
/opt/tools/*
/etc/profile.d/tools.sh

%changelog
* Mon May 18 2020 Brett Kelly <bkelly@45drives.com> 1.1
- Third build, link files from opt/tools to bin dir
* Mon May 18 2020 Brett Kelly <bkelly@45drives.com> 1.1
- Second build added zfs check in profile.d script. Organized code. Removed uneeded scripts
* Mon May 11 2020 Josh Boudreau <jboudreau@45drives.com> 1.0
- First build from GitHub source
