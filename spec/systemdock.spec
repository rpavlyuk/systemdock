%define         _module systemdock

# SVAROG-related variables
%{!?svn_revision:%define svn_revision 1}
# COMPATIBILITY FIX: Jenkins job name is neccessary to make build root unique (for CentOS5 and earlier)
%{!?JOB_NAME:%define JOB_NAME standalone}


Name:		systemdock
Version:	0.2
Release:	%{svn_revision}%{?dist}
Summary:	Toolset to run Docker containers as systemd service

Group:		System/Tools
License:	GPLv3
URL:		https://github.com/rpavlyuk/systemdock
Packager:       Roman Pavlyuk <roman.pavlyuk@gmail.com>
Source:         %{_module}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)-%{JOB_NAME}
BuildArch:      noarch

Requires:	python3
Requires:	docker	
Requires:	python3-docker-py
Requires:	python3-PyYAML

%description
Toolset to run Docker containers as systemd service on RedHat and other Linux systems

%prep
%setup -n %{_module}

%build
# Nothing

%install
%make_install


%files
%doc README.md

%config(noreplace) %{_sysconfdir}/systemdock/config.yaml
%dir %{_sysconfdir}/systemdock/containers.d
%{_datadir}/systemdock/templates/*

%attr(0755,root,root) %{_bindir}/systemdock

%changelog

