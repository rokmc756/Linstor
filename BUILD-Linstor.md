# Build OS Environment
Rocky Linux 9.x Latest Version


# Download Linstor Sources
https://linbit.com/linbit-software-download-page-for-linstor-and-drbd-linux-driver/#linstor
```
cd /root/rpmbuild/SOURCES

wget https://linbit.gateway.scarf.sh/downloads/linstor/linstor-server-1.30.4.tar.gz
wget https://linbit.gateway.scarf.sh/downloads/linstor/python_linstor-1.25.0.tar.gz
wget https://linbit.gateway.scarf.sh/downloads/linstor/linstor-client-1.23.2.tar.gz
wget https://linbit.gateway.scarf.sh/downloads/connectors/linstor-proxmox-8.1.0.tar.gz       # It only include debian spec
```


# Enable Repository
```
dnf config-manager --set-enabled crb
dnf config-manager --set-enabled devel
```


# Install Packages and Update Kernel
```bash
dnf install -y java-11-* asciidoctor selinux-policy-devel kernel-abi-stablelists kernel-devel kernel-rpm-macros po4a rpm-build
dnf update -y kernel
```


# Fix Java 11 Version
```bash
update-alternatives --config java
```


# Install Gradle
```
wget https://services.gradle.org/distributions/gradle-7.5.1-bin.zip
mkdir /opt/gradle
unzip -d /opt/gradle gradle-7.5.1-bin.zip
export PATH=$PATH:/opt/gradle/gradle-7.5.1/bin
vi ~/.bashrc
```


# Check Packages to be built
``` bash
cat roles/satellite/meta/main.yaml
~~ snip
      lb_rpm_pkgs: ["kmod-drbd", "drbd", "linstor-controller", "linstor-client", "linstor-satellite", "python-linstor"],
~~ snip
```


# Build Linstor GUI
```bash
git clone https://github.com/LINBIT/linstor-gui
cd linstor-gui/
git checkout v1.9.3
cp linstor-gui.spec /root/rpmbuild/SPECS/
wget https://linbit.gateway.scarf.sh/downloads/linstor/linstor-gui-1.9.3.tar.gz
mv linstor-gui-1.9.3.tar.gz /root/rpmbuild/SOURCES
cd /root/rpmbuild/SPECS
rpmbuild -ba linstor-gui.spec
~~ snip
Wrote: /root/rpmbuild/SRPMS/linstor-gui-1.9.3-1.src.rpm
Wrote: /root/rpmbuild/RPMS/noarch/linstor-gui-1.9.3-1.noarch.rpm
~~ snip
```


# Build Linstor Server
```bash
git clone https://github.com/LINBIT/linstor-server
cd linstor-server/
git checkout v1.30.4
cp linstor.spec /root/rpmbuild/SPECS/
cd /root/rpmbuild/SPECS/
rpmbuild -ba linstor.spec
~~ snip
Wrote: /root/rpmbuild/SRPMS/linstor-1.30.4-1.el9.src.rpm
Wrote: /root/rpmbuild/RPMS/noarch/linstor-satellite-1.30.4-1.el9.noarch.rpm
Wrote: /root/rpmbuild/RPMS/noarch/linstor-controller-1.30.4-1.el9.noarch.rpm
Wrote: /root/rpmbuild/RPMS/noarch/linstor-common-1.30.4-1.el9.noarch.rpm
~~ snip
```


# Build Linstor Client
``` bash
git clone https://github.com/LINBIT/linstor-client
cd linstor-client/
git checkout v1.23.2
make rpm
~~ snip
moving build/bdist.linux-x86_64/rpm/SRPMS/linstor-client-1.23.2-1.src.rpm -> dist
moving build/bdist.linux-x86_64/rpm/RPMS/noarch/linstor-client-1.23.2-1.noarch.rpm -> dist
~~ snip
mv linstor-client-1.23.2-1.src.rpm /root/rpmbuild/SRPMS/
mv linstor-client-1.23.2-1.noarch.rpm /root/rpmbuild/RPMS/noarch/
```


# Build Python Linstor
```
tar xvzf python_linstor-1.25.0.tar.gz
cd python_linstor-1.25.0/
make rpm
~~ snip
moving build/bdist.linux-x86_64/rpm/SRPMS/python-linstor-1.25.0-1.src.rpm -> dist
moving build/bdist.linux-x86_64/rpm/RPMS/noarch/python-linstor-1.25.0-1.noarch.rpm -> dist
mv python-linstor-1.25.0-1.noarch.rpm /root/rpmbuild/RPMS/noarch/
mv python-linstor-1.25.0-1.src.rpm /root/rpmbuild/SRPMS/
```

