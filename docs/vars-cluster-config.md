# Cluster Configuration Variable Structure & Definition

Below you can find the structure of the variables file for the cluster configuration, the variable definitions, etc.

```yaml
---
##################################################
# SSH Key Configuration
##################################################
## You can have a unique SSH Key pair generated for each cluster,
## or you can define a preexisting SSH Key pair that will be used for this cluster.

# generate_ssh_key: true/false, will generate unique key pair if true
generate_ssh_key: true

# ssh_pub_key_path: If 'generate_ssh_key' is false, point to an existing SSH Public Key
#ssh_pub_key_path: "~/.ssh/id_rsa.pub"

##################################################
# OpenShift Pull Secret
##################################################
# pull_secret: Often best to pull from a file outside of the repo, remove any whitespace - get it from here: https://cloud.redhat.com/openshift/install/pull-secret
pull_secret_path: ~/ocp-pull-secret

# pull_secret: You can override this variable if you prefer to pass the pull secret as a variable directly
pull_secret: "{{ lookup('file', pull_secret_path) | to_json }}"

##################################################
# Red Hat API Offline Token
##################################################
# rh_api_offline_token: If using the RH Cloud Assisted Installer service, you will need an Offline API Token from this page: https://access.redhat.com/management/api
rh_api_offline_token_path: "/mnt/remoteWork/rh-api-offline-token"

# rh_api_offline_token: You can override this variable if you prefer to pass the Offline API Token as a variable directly
rh_api_offline_token: "{{ lookup('file', rh_api_offline_token_path) }}"

##################################################
# Cluster Basics
##################################################
# cluster_type: Standard (HA CP+App Nodes), SNO (Single Node OpenShift)
cluster_type: Standard

# cluster_version can be x.y or x.y.z - must be formatted as a STRING
cluster_version: "4.10"

# cluster_name and cluster_domain will form the cluster base endpoint, eg cluster_name.cluster_domain
# Ensure the DNS A records for {api,api-int,*.apps}.cluster_name.cluster_domain exist
cluster_name: vsphere-ocp-ha
cluster_domain: kemo.labs

##################################################
# Cluster Networking
##################################################
# cluster_api_vip: an IP or "auto"
cluster_api_vip: 192.168.42.88

# cluster_apps_vip: an IP or "auto"
cluster_apps_vip: 192.168.42.89

# cluster_node_cidr: A CIDR definition of the subnet the VMs live in or "auto"
cluster_node_cidr: 192.168.42.0/24

##################################################
# Cluster Node IPAM
##################################################
# cluster_node_network_ipam: dhcp or static
cluster_node_network_ipam: static

# cluster_node_network_static_dns_servers - a list of IPs for DNS Servers
cluster_node_network_static_dns_servers:
  - 192.168.42.9
  - 192.168.42.10

# cluster_node_network_static_dns_search_domains - a list of DNS Search Domains
cluster_node_network_static_dns_search_domains:
  - kemo.labs

##################################################
# Cluster Nodes
##################################################
# cluster_nodes is the structure that defines the actual nodes in the cluster

cluster_nodes:
  - name: cp-1 # must be unique and dns compliant
    # type: control-plane | application-node | converged | sno | infra-node
    type: control-plane
    # infra is the name/type pair that matchs a infrastructure_providers variable entry
    infra:
      name: labRaza
      # type: vsphere | nutanix | libvirt
      type: libvirt
    vm:
      cpu_cores: 4
      cpu_sockets: 1
      cpu_threads: 1
      memory: 16384 # in MB
      # disks - a list of disks
      disks:
        - size: 130 # in GB
          name: boot # must be unique
          # [optional, supported on Libvirt/vSphere] type: thin | thick
          type: thin
    networking:
      # interfaces - a list of interfaces, at least one needs to be provided
      interfaces:
        - name: eth0 # must be unique - eth0/enp1s0 on Libvirt, ens3 on Nutanix, ens192 on vSphere
          # dhcp: true | false
          dhcp: false
          # mac_address: If using Static Networking then a unique MAC address needs to be defined - if using DHCP, you can omit
          mac_address: 54:52:00:42:69:11
          ipv4:
            - address: 192.168.42.90
              prefix: 24
          # [optional, supported on Libvirt] libvirt_network, if not specified, will use the network defined in the infrastructure provider configuration
          libvirt_network: "lanBridge"
          # [optional, supported on Nutanix] nutanix_network, if not specified, will use the network defined in the infrastructure provider configuration
          nutanix_network: "lanBridge"
          # [optional, supported on vSphere] vmware_network, if not specified, will use the network defined in the infrastructure provider configuration
          vmware_network: "lanBridge"
      # [optional] routes: a list of routes
      routes:
        - destination: 0.0.0.0/0
          next_hop_address: 192.168.42.1
          next_hop_interface: eth0 # must be in the interfaces list
          table_id: 254

  # ...
  # Add as many node items as you want in the cluster...
  # ...

```