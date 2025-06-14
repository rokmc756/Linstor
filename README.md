### What is Linstro?
Linstor is an open-source software-defined storage solution that is typically used to manage DRBD replicated storage volumes.
It provides both highly available and high performance volumes while focusing on operational simplicity.

Linstor does not manage the underlying storage by itself and instead relies on other components such as ZFS or LVM to provision block devices.
These block devices are then replicated using DRBD to provide fault tolerance and the ability to mount the volumes on any cluster node,
regardless of its storage capabilities. Since volumes are replicated using the DRBD kernel module, the data path for the replication is kept
entirely on kernel space, reducing its overhead when compared to solutions implemented in user space.


### Linstro Storage Architecture
#### Diagram
<p align="center">
<img src="https://github.com/rokmc756/Linstor/blob/main/roles/cluster/images/linstor-public-architecture.svg" width="70%" height="70%">
</p>

**`The Linstor system consists of multiple server and client components`**:
  - A Linstor controller manages the configuration of the Linstor cluster and all its managed storage resources.
  - The Linstor satellite component manages the creation, modification, and deletion of storage resources on each node that provides or uses Linstor-managed storage resources.
  - All communication between Linstor components use Linstor’s network protocol, based on TCP/IP network connections.
  - Manage the storage system by using a command-line utility to interact with the active Linstor controller.
  - Alternatively, integrate the Linstor system into the storage architecture of other software systems, such as Kubernetes.


#### Abstracting block storage
<p align="center">
<img src="https://github.com/rokmc756/Linstor/blob/main/roles/cluster/images/linstor-internal-architecture.png" width="70%" height="70%">
</p>

**`Linstor SDS`**:
  - It manages various open source block storage technologies commonly found in modern Linux distributions to apply enterprise grade features such as encryption at rest, caching, and deduplication to storage volumes across storage clusters.
  - It consists of a single controller service, and usually many satellite service instances running within a cluster of nodes.
  - The node running the controller service is responsible for managing the cluster configurations and orchestrating operations to be carried out on the nodes running a satellite service instance.
  - The satellite nodes in the cluster either provide or access Linstor managed storage directly.
  - Satellites are also responsible for provisioning logical volumes and layering block storage technologies, as instructed by the user through configurations made against the controller.
  - Most users are interested in using Linstor to manage DRBD devices, enabling synchronous and asynchronous replication, in their block storage.
  - Once you’ve added physical devices to a cluster node, whether that node is a physical or virtual server in your local data center or a virtual server in the AWS cloud, management of the device and any logical volumes created from it are now handled from a single unified management plane – the controller node.
  - The same is true for monitoring the block storage.
  - It exposes metrics about the cluster and the storage resources it manages which can be scraped by Prometheus which enables you to monitor storage across a hybrid cloud environment in a uniform manner.
  - The Linstor GUI also offers users a single-pane of glass for observing and managing storage resources in the cluster.

#### Exos Integration
<p align="center">
<img src="https://github.com/rokmc756/Linstor/blob/main/roles/cluster/images/linstor-exos-integration.png" width="70%" height="70%">
</p>

**`Exos Storage`**:
  - The Exos storage manager from Seagate could be configured as one large block device managed by Linstor such as a local drive, but this would prevent concurrent sharing of Linstor resources between multiple servers out of the same pool.
  - Linstor integration with Exos enables multiple server nodes to allocate and connect to Linstor resources serviced by the same Exos pool.
  - Therefore all of the Exos storage management features such as SSD/HDD tiering, SSD caching, snapshots, and thin provisioning are available for Linstor resources and Kubernetes Storage Classes.
  - After configuration, Linstor will dynamically map Resource replicas as LUNs presented to server nodes through one of the two Exos controllers.
  - Since the Exos controllers are managed by a secure network API, Linstor must be configured with proper networking and username and password combination.
  - The diagram below is showing the relationship between Linstor cluster and Exos Enclosures.
  - Load balancing and server failover are managed & enabled by Linstor while volume creation is handled by the Exos hardware RAID engine.
  - The Exos storage provider in Linstor offers native integration with Exos’ REST-API.


### Linstor Ansible Playbook
This Ansible Playbook provides the feature to build a Linstor Cluster on Baremetal, Virtual Machines.
The main purposes of this project are simple to deploy Linstor Cluster quickly and interact with Incus Cluster and learn knowleges about it.
If you're unfamiliar with Linstor, please refer to the
[Introduction to Linstor section](https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/#p-linstor-introduction)
of the Linstor user's guide on https://linbit.com to learn more.

**`System requirements`**:
  - Deployment environment must have Ansible `2.7.0+` and `python-netaddr`.
  - All target systems must have passwordless SSH access.
  - All hostnames used in the inventory file are resolvable (or use IP addresses).
  - Target systems are Ubuntu 24.04 currently verified (or compatible variants).
  - MacOS or Linux(or WSL) should have installed ansible as Ansible Host.
  - Supported OS for ansible target host should be prepared with apt package repository configured
  - At least a Normal User which has Sudo Privileges


### Prepare ansible host to run this playbook
* MacOS
```bash
$ xcode-select --install
$ brew install ansible
$ brew install https://raw.githubusercontent.com/kadwanev/bigboybrew/master/Library/Formula/sshpass.rb
```

### Where is it originated?
It has been developing based on the following project - https://github.com/LINBIT/linstor-ansible.
Since above project is not useful to me I modified it with make utility and uninstall tasks for controller/satellite/storage.


### Verified Linstor Version
* Linstor 1.30.x


### Supported Platform and OS
* Virtual Machines
* Baremetal
* Ubuntu 24.x


### Usage
Add the target system information into the inventory file named `ansible-hosts-ubt24`.
For example:
```ini
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

You can add a `controller` node to the `satellite` node group which will result in the node becoming a `Combined` node in the Linstor cluster.
A `Combined` node will function both as a `controller` and as a `satellite` node.
Add nodes to the `storage` node group to contribute block storage to the Linstor storage pool created by the playbook.

Also, before continuing, edit `group_vars/all.yaml` to configure the necessary variables for the playbook. For example:
```yaml
$ vi group_vars/all.yaml
---
ansible_ssh_pass: "changeme"
ansible_become_pass: "changeme"
ansible_ssh_private_key_file: ~/.ssh/ansible_key

# Linstor variables
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

The `_linstor.storage` variable should be set to an unused block device that the Linstor satellite nodes will use if the nodes are also a part of the `storage` node group.
If you do not have an unused block device, do not add the node to the `storage` node group, and only a `file-thin` storage-pool will be configured instead.
The `drbd_replication_network` is the network, in CIDR notation, that will be used by Linstor and DRBD. It is strongly recommended that the `drbd_replication_network` be separate from the management network in
production systems to limit network traffic congestion, but it's not a hard requirement.

When ready, run the make commands
### Initialize or Uninitialize Linux Host to install packages required and generate/exchange ssh keys among all hosts.
```bash
$ make hosts r=init          # or uninit
```

### Preapre or Clean Linstor Cluster such as Package Installation
```bash
$ make cluster r=prepare     # or clean
```

### Install Linstor Controller
```bash
$ make controller r=enable s=firewall
$ make controller r=setup  s=service

or
$ make controller r=install s=all
```

### Install Linstor Controller
```bash
$ make controller r=remove  s=service
$ make controller r=disable s=firewall

or
$ make controller r=uninstall s=all
```

### Install Linstor Satellite
```bash
$ make satellite r=enable s=firewall
$ make satellite r=setup  s=service

or
$ make satellite r=install s=all
```

### Uninstall Linstor Satellite
```bash
$ make satellite r=remove  s=service
$ make satellite r=disable s=firewall

or
$ make satellite r=uninstall s=all
```

### Install Linstor Storage Pools
```bash
$ make storage r=create s=lvmthin
$ make storage r=create s=zfshin
$ make storage r=create s=lvm
$ make storage r=create s=zfs
$ make storage r=create s=filethin

or
$ make storage r=install s=all
```

### Uninstall Linstor Storage Pools
```bash
$ make storage r=delete s=filethin
$ make storage r=delete s=zfs
$ make storage r=delete s=lvm
$ make storage r=delete s=zfsthin
$ make storage r=delete s=lvmthin

or
$ make storage r=uninstall s=all
```


### Testing Installation
Shell into the controller node, and check that everything is setup:
```bash
$ linstor node list; linstor storage-pool list
```
Create and deploy a resource:

```bash
$ linstor resource-definition create test-res-0
$ linstor volume-definition create test-res-0 100MiB
$ linstor resource create \
  $(linstor sp list | head -n4 | tail -n1 | cut -d"|" -f3 | sed 's/ //g') \
  test-res-0 --storage-pool lvm-thin
$ linstor resource list
```
You should now have a DRBD device provisioned on a node in your cluster that you
can use as you would any other block device.


### Open Linstor Web Console
Open web brower and type `http://<controller's ip address>:3370`


### Reference
- For building Linstor RPM Packages from Sources - refer to [Build Linstor RPM Packages](https://github.com/rokmc756/Linstor/blob/main/BUILD-Linstor.md)
- For more instructions for Kubernetes, OpenStack, Docker, or other integration - refer to [Linstor Documentation](https://linbit.com/drbd-user-guide/linstor-guide-1_0-en/).
- For more Linstore concepts and configurations - refer to [Linstor: Concepts and Configuration](https://brian-candler.medium.com/linstor-concepts-and-configuration-e5b0c8e10d27)

