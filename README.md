## What is Linstro?
LINSTOR is an open-source software-defined storage solution that is typically used to manage DRBD replicated storage volumes.
It provides both highly available and high performance volumes while focusing on operational simplicity.

LINSTOR does not manage the underlying storage by itself and instead relies on other components such as ZFS or LVM to provision block devices.
These block devices are then replicated using DRBD to provide fault tolerance and the ability to mount the volumes on any cluster node,
regardless of its storage capabilities. Since volumes are replicated using the DRBD kernel module, the data path for the replication is kept
entirely on kernel space, reducing its overhead when compared to solutions implemented in user space.


## Linstro Storage Architecture

<p align="center">
<img src="https://github.com/rokmc756/Linstor/blob/main/roles/cluster/images/linstor-public-architecture.svg" width="70%" height="70%">
</p>

<p align="center">
<img src="https://github.com/rokmc756/Linstor/blob/main/roles/cluster/images/linstor-internal-architecture.png" width="70%" height="70%">
</p>

<p align="center">
<img src="https://github.com/rokmc756/Linstor/blob/main/roles/cluster/images/linstor-exos-integration.png" width="70%" height="70%">
</p>


## Linstor Ansible Playbook
This Ansible Playbook provides the feature to build a Linstor Cluster on Baremetal, Virtual Machines.
The main purposes of this project are simple to deploy Linstor Cluster quickly and interact with Incus Cluster and learn knowleges about it.
If you're unfamiliar with Linstor, please refer to the
[Introduction to LINSTOR section](https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/#p-linstor-introduction)
of the Linstor user's guide on https://linbit.com to learn more.

System requirements:
  - Deployment environment must have Ansible `2.7.0+` and `python-netaddr`.
  - All target systems must have passwordless SSH access.
  - All hostnames used in the inventory file are resolvable (or use IP addresses).
  - Target systems are Ubuntu 24.04 currently verified (or compatible variants).
  - MacOS or Linux(or WSL) should have installed ansible as Ansible Host.
  - Supported OS for ansible target host should be prepared with apt package repository configured
  - At least a Normal User which has Sudo Privileges


## Prepare ansible host to run this playbook
* MacOS
```!yaml
$ xcode-select --install
$ brew install ansible
$ brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```


## Where is it originated?
It has been developing based on the following project - https://github.com/LINBIT/linstor-ansible.
Since above project is not useful to me I modified it with make utility and uninstall tasks for controller/satellite/storage.


## Verified Linstor Version
* Linstor 1.30.x


## Supported Platform and OS
* Virtual Machines
* Baremetal
* Ubuntu 24.x


## Usage
Add the target system information into the inventory file named `ansible-hosts-ubt24`.
For example:
```
[all:vars]
ssh_key_filename="id_rsa"
remote_machine_username="jomoon"
remote_machine_password="changeme"

[controller]
ubt24-node06 ansible_ssh_host=192.168.1.86

[satellite]
ubt24-node07 ansible_ssh_host=192.168.1.87
ubt24-node08 ansible_ssh_host=192.168.1.88
ubt24-node09 ansible_ssh_host=192.168.1.89

[cluster:children]
controller
satellite

[storage]
ubt24-node07 ansible_ssh_host=192.168.1.87
ubt24-node08 ansible_ssh_host=192.168.1.88
ubt24-node09 ansible_ssh_host=192.168.1.89
~~ snip
```

You can add a `controller` node to the `satellite` node group which will result in the node becoming a `Combined` node in the LINSTOR cluster.
A `Combined` node will function both as a `controller` and as a `satellite` node.
Add nodes to the `storage` node group to contribute block storage to the LINSTOR storage pool created by the playbook.

Also, before continuing, edit `group_vars/all.yaml` to configure the necessary variables for the playbook. For example:
```
$ vi group_vars/all.yaml
---
ansible_ssh_pass: "changeme"
ansible_become_pass: "changeme"
ansible_ssh_private_key_file: ~/.ssh/ansible_key

# LINSTOR variables
drbd_replication_network: 192.168.1.0/24

# LINBIT Portal Variables
lb_user: ""
lb_pass: ""
lb_con_id: ""
lb_clu_id: ""
~~ snip
  storage:
    - { storage_pool: 'lvmthin_pool01',  pool_name: 'lvmthin_pool01',  storage_dev: '/dev/nvme0n1', type: 'lvmthin' }
    - { storage_pool: 'zfsthin_pool02',  pool_name: 'zfsthin_pool02',  storage_dev: '/dev/nvme0n2', type: 'zfsthin' }
    - { storage_pool: 'lvm_pool01',      pool_name: 'lvm_pool01',      storage_dev: '/dev/sdb',     type: 'lvm' }
    - { storage_pool: 'zfs_pool02',      pool_name: 'zfs_pool02',      storage_dev: '/dev/sdc',     type: 'zfs' }
~~ snip
```

The `_linstor.storage` variable should be set to an unused block device that the LINSTOR satellite nodes will use if the nodes are also a part of the `storage` node group.
If you do not have an unused block device, do not add the node to the `storage` node group, and only a `file-thin` storage-pool will be configured instead.
The `drbd_replication_network` is the network, in CIDR notation, that will be used by LINSTOR and DRBD. It is strongly recommended that the `drbd_replication_network` be separate from the management network in
production systems to limit network traffic congestion, but it's not a hard requirement.

When ready, run the `setup-temp.yml.tmp` playbook:
## Preapre or Clean Linstor Cluster such as Package Installation
```sh
make cluster r=prepare

or
make cluster r=clean
```

## Install or Uninstall Linstor Controller
```sh
make controller r=install

or
make controller r=uninstall
```

## Install or Uninstall Linstor Satellite
```sh
make satellite r=install

or
make satellite r=uninstall
```

## Install or Uninstall Linstor Storage Pools
```sh
make storage r=install

or
make storage r=uninstall
```

## Testing Installation
Shell into the controller node, and check that everything is setup:
```sh
linstor node list; linstor storage-pool list
```
Create and deploy a resource:

```sh
linstor resource-definition create test-res-0
linstor volume-definition create test-res-0 100MiB
linstor resource create \
  $(linstor sp list | head -n4 | tail -n1 | cut -d"|" -f3 | sed 's/ //g') \
  test-res-0 --storage-pool lvm-thin
linstor resource list
```
You should now have a DRBD device provisioned on a node in your cluster that you
can use as you would any other block device.


## Reference
For more information on LINSTOR - such as instructions for Kubernetes,
OpenStack, Docker, or other integration - refer to
[LINBIT's LINSTOR documentation](https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/).


## Linstor: Concepts and Configuration
https://brian-candler.medium.com/linstor-concepts-and-configuration-e5b0c8e10d27

