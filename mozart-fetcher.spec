Name: mozart-fetcher
Version: %{version}
Release: 1%{?dist}
License: MPL-2.0
Group: Development/Frameworks
URL: https://github.com/bbc/mozart-fetcher
Summary: Fans-out requests and returns aggregated content
Packager: BBC News Frameworks and Tools

Source0: mozart_fetcher.tar.gz
Source1: mozart-fetcher.service
Source2: bake-scripts.tar.gz
Source3: component-status-cfn-signal.sh
Source4: cloudformation-signal.service

BuildRoot: /root/rpmbuild
BuildArch: x86_64

Requires: amazon-cloudwatch-agent
Requires: component-logger
Requires: aws-cfn-bootstrap

%description
mozart-fetcher is a service for fetching multiple components
in parallel and aggregating the responses.

%pre
/usr/bin/getent group component >/dev/null || groupadd -r component
/usr/bin/getent passwd component >/dev/null || useradd -r -g component -G component -s /sbin/nologin -c 'component service' component

%install
mkdir -p %{buildroot}/home/component
mkdir -p %{buildroot}/home/component/mozart-fetcher
mkdir -p %{buildroot}/usr/lib/systemd/system
mkdir -p %{buildroot}/etc/bake-scripts/%{name}
tar -C %{buildroot}/home/component/mozart-fetcher -xzf %{SOURCE0}
tar -C %{buildroot}/etc/bake-scripts/%{name} -xzf %{SOURCE2} --strip 1
cp %{SOURCE1} %{buildroot}/usr/lib/systemd/system/mozart-fetcher.service
mkdir -p %{buildroot}/etc/systemd/system/mozart-fetcher.service.d
touch %{buildroot}/etc/systemd/system/mozart-fetcher.service.d/env.conf
cp %{SOURCE3} %{buildroot}/home/component/component-status-cfn-signal.sh
cp %{SOURCE4} %{buildroot}/usr/lib/systemd/system/cloudformation-signal.service
mkdir -p %{buildroot}/var/log/component
touch %{buildroot}/var/log/component/app.log
mkdir -p %{buildroot}/etc/mozart-fetcher
touch %{buildroot}/etc/mozart-fetcher/environment
touch %{buildroot}/etc/mozart-fetcher/config.json

%post
systemctl enable mozart-fetcher
systemctl enable cloudformation-signal
/bin/chown -R component:component /home/component
/bin/chown -R component:component /var/log/component
/bin/chown -R component:component /etc/mozart-fetcher/config.json

%files
%attr(0755, component, component) /home/component/*
/usr/lib/systemd/system/cloudformation-signal.service
/usr/lib/systemd/system/mozart-fetcher.service
/var/log/component/app.log
/etc/bake-scripts/%{name}
/etc/systemd/system/mozart-fetcher.service.d/env.conf
%attr(0644, component, component) /etc/mozart-fetcher/environment
%attr(0644, component, component) /etc/mozart-fetcher/config.json
