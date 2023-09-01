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

Requires: cosmos-ca-bundler cosmos-ca-tools
Requires: amazon-cloudwatch-agent
Requires: component-logger

%description
mozart-fetcher is a service for fetching multiple components
in parallel and aggregating the responses.

# ERROR: ambiguous python shebang in ffi-1.15.5 lib
# We disable shebang because of the error (more info: https://docs.fedoraproject.org/en-US/packaging-guidelines/#_shebang_lines)
%undefine __brp_mangle_shebangs

%pre
/usr/bin/getent group component >/dev/null || groupadd -r component
/usr/bin/getent passwd component >/dev/null || useradd -r -g component -G component -s /sbin/nologin -c 'component service' component
/usr/bin/chsh -s /bin/bash component

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

%post
systemctl enable mozart-fetcher
systemctl enable cloudformation-signal
/bin/chown -R component:component /home/component
/bin/chown -R component:component /var/log/component

%files
/home/component
%attr(0755, component, component) /home/component/component-status-cfn-signal.sh
/usr/lib/systemd/system/cloudformation-signal.service
/usr/lib/systemd/system/mozart-fetcher.service
/var/log/component/app.log
/etc/bake-scripts/%{name}
/etc/systemd/system/mozart-fetcher.service.d/env.conf
