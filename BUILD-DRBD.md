# Build OS Environment
Rocky Linux 9.x Latest Version


# Download Linstor Sources
https://linbit.com/linbit-software-download-page-for-linstor-and-drbd-linux-driver/#linstor

```
cd /root/rpmbuild/SOURCES

wget https://linbit.gateway.scarf.sh/downloads/drbd/9/drbd-9.2.13.tar.gz
wget https://linbit.gateway.scarf.sh/downloads/drbd/utils/drbd-utils-9.30.0.tar.gz
wget https://linbit.gateway.scarf.sh/downloads/drbd/utils/drbd-reactor-1.8.0.tar.gz
wget https://linbit.gateway.scarf.sh/downloads/drbd/8/drbd-8.4.11-1.tar.gz

```


# Build DRBD Utils
```bash
git clone https://github.com/LINBIT/drbd-utils
cd drbd-utils/
git checkout v9.30.0
./autogen.sh
./configure --enable-spec
cp drbd.spec /root/rpmbuild/SPECS
dnf install keyutils-libs-devel
rpmbuild -ba drbd.spec
~~ snip
Wrote: /root/rpmbuild/SRPMS/drbd-9.30.0-1.el9.src.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-selinux-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-xen-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-bash-completion-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-heartbeat-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-udev-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-man-ja-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-pacemaker-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-utils-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-debugsource-9.30.0-1.el9.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-utils-debuginfo-9.30.0-1.el9.x86_64.rpm
~~ snip
```


# Build DRBD Reactor
```bash
git clone https://github.com/LINBIT/drbd-reactor
git checkout v1.8.0
cp drbd-reactor.spec /root/rpmbuild/SPECS/
dnf install cargo
rpmbuild -ba drbd-reactor.spec
~~ snip
Wrote: /root/rpmbuild/SRPMS/drbd-reactor-1.8.0-1.src.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-reactor-1.8.0-1.x86_64.rpm
~~ snip
```


# Build DRBD
```bash
git clone https://github.com/LINBIT/drbd
git checkout drbd-9.2.13
cp drbd-kernel.spec /root/rpmbuild/SPECS/
cd /root/rpmbuild/SPECS/
rpmbuild -ba drbd-kernel.spec
~~ snip
Wrote: /root/rpmbuild/SRPMS/drbd-kernel-9.2.13-1.src.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/drbd-kernel-debugsource-9.2.13-1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/kmod-drbd-9.2.13_5.14.0_503.33.1-1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/kmod-drbd-debuginfo-9.2.13_5.14.0_503.33.1-1.x86_64.rpm
~~ snip
```

