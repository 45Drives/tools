%define        __spec_install_post %{nil}
%define          debug_package %{nil}
%define        __os_install_post %{_dbpath}/brp-compress

Name:		tools
Version:	1.0
Release:	1%{?dist}
Summary:	Server CLI Tools

Group:		Development/Tools
License:	GPL
URL:		https://github.com/45Drives/tools
Source0:	%{name}-%{version}.tar.gz

BuildArch:	noarch
BuildRoot:	%{_tmppath}/%{name}-%{version}-%{release}-root

%description

45Drives server tools

%prep
%setup -q

%build
# empty

%install
rm -rf %{buildroot}
mkdir -p  %{buildroot}

# in builddir
cp -a * %{buildroot}

%clean
rm -rf %{buildroot}

%files
%dir /opt/tools
%dir /etc/profile.d
%defattr(-,root,root,-)
/opt/tools/*
/usr/bin/*
/etc/profile.d/tools.sh

%changelog
* Mon May 11 2020 Josh Boudreau <jboudreau@45drives.com> 1.0
- First build from GitHub source
