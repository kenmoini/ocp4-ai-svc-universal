# OpenShift Assisted Installer Service, Universal Deployer

This set of resources handles an idempotent way to deploy OpenShift via the Assisted Installer Service to any number of infrastructure platforms.

## Features

- Use the Red Hat hosted Assisted Installer or your own hosted Assisted Installer Service
- End to end deployment and destruction of OpenShift clusters from a bit of YAML and a single command
- Deploy to different ***AND*** multiple infrastructure platforms
- Pre-installation configuration of:
  - Additional Root CA Trust Bundles
  - Custom CNIs like Calico and Cilium
  - Injecting additional manifests and ignition overrides
  - Multiple Disks
  - Multiple Network Interfaces, on different networks, with NMState-based configurations
  - NTP Servers
- Post-installation configuration of OpenShift with Roles such as:
  - ocp4-certificates for custom Root and Load Balancer certificates
  - ocp4-deploy-nutanix-csi to deploy the Nutanix CSI
  - ocp4-mario-game for a fun demo workload
  - ocp4-ntp-configuration to configure chrony/ntp
  - ocp4-red-matrix-login to configure the drippy Red Matrix Login
  - ocp4-rhsm-entitlement to apply Red Hat Subscription Manager Entitlement for entitled builds

### Supported Infrastructure Platforms

- Libvirt/KVM, tested with RHEL 8.5 and RHEL 9.1
- Nutanix AHV, tested with Nutanix CE
- VMWare, tested with vSphere 7+
- Bare Metal, tested with Dell and Sushy-tools - automation for HP and Supermicro also available

### Upcoming Infrastructure Platforms

- HyperV
- OpenStack

---

## Operations

The following tasks performed by the different Playbooks are:

### bootstrap.yaml

- Preflight for binaries, create asset generation directory, set HTTP Headers & Authentication
- Preflight checks for supported OpenShift versions on the Assisted Installer Service
- Preflight to do connectivity tests to infrastructure platforms
- Query the AI Svc, check for existing cluster with the same name, set facts if so
- Set needed facts, or create a new cluster with new SSH keys
- Configure cluster on the AI Svc with Cluster/InfraEnv deployment specs and ISO Params
- Download the generated Discovery ISO
- Upload the generated Discovery ISO to the target infrastructure platforms
- Create & boot the needed infrastructure resources on the target infrastructure platforms
- Wait for the hosts to report into the AI Svc
- Set Host Names and Roles on the AI Svc
- Set Network VIPs on the AI Svc
- Wait for the hosts to be ready
- Start the cluster installation on the AI Svc
- Wait for the cluster to be fully installed
- Pull cluster credentials from the AI Svc

### destroy.yaml

- Preflight for setting HTTP Headers & Authentication
- Preflight to do connectivity tests to infrastructure platforms
- Query the AI Svc, check for existing cluster with the same name, set facts if so
- Power off & delete the infrastructure compute on the target infrastructure platforms
- Delete the Discovery ISO and other shared items from the target infrastructure platforms
- Delete the cluster from the AI Svc
- Delete local generated cluster files

### extras-create-sushy-bmh.yaml

This extra Playbook will create some VMs on a Libvirt or VMWare infrastructure provider that will not be turned on in order to act as virtual Bare Metal Hosts via sushy-tools.

- Perform connectivity tests to infrastructure platforms
- Create the virtual infrastructure resources on the target infrastructure platforms

```bash
ansible-playbook -e "@credentials-infrastructure.yaml" \
  --skip-tags=infra_libvirt_boot_vm,vmware_boot_vm,infra_libvirt_per_provider_setup,vmware_upload_iso \
  extras-create-sushy-bmh.yaml
```

---

## Prerequisites

- Ansible Automation - `python3 -m pip install ansible`
- cURL - `dnf install curl`
- Git - `dnf install git`
- jq - `dnf install jq`

### Red Hat Registry Pull Secret

To deploy OpenShift in a connected environment, you need to provide a registry pull secret.  Get yours from here: https://cloud.redhat.com/openshift/install/pull-secret

It's suggested to use the Copy-to-Clipboard button to copy the registry pull secret to the clipboard.  Then, paste it into a file somewhere like `~/ocp-pull-secret` - make sure there is no white space in the JSON structure.

### Red Hat API Offline Token

To use the Red Hat hosted Assisted Install Service, you need to provide a Red Hat API Offline Token.  Get yours from here: https://access.redhat.com/management/api

Take the token and store it in a file somewhere like `~/rh-api-offline-token`

### One-time | Installing oc

There are a few Ansible Tasks that use the `command` module to execute commands best/easiest serviced by the `oc` binary - thusly, `oc` needs to be available in the system path

```bash
## Create a binary directory if needed
sudo mkdir -p /usr/local/bin
echo 'export PATH="/usr/local/bin:$PATH"' | sudo tee /etc/profile.d/usrlibbin.sh
sudo chmod a+x /etc/profile.d/usrlibbin.sh
source /etc/profile.d/usrlibbin.sh

## Download the latest oc binary
mkdir -p /tmp/bindl
cd /tmp/bindl
wget https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-client-linux.tar.gz
tar zxvf openshift-client-linux.tar.gz

## Set permissions and move it to the bin dir
sudo chmod a+x kubectl
sudo chmod a+x oc

sudo mv kubectl /usr/local/bin
sudo mv oc /usr/local/bin

## Clean up
cd -
rm -rf /tmp/bindl
```

---

## Usage

### Clone the repo

```bash
git clone http://github.com/kenmoini/ocp4-ai-svc-universal.git
cd ocp4-ai-svc-universal
```
### One-time | Installing Needed Pip Packages

Before running this Ansible content, you will need to install the `kubernetes` and `openshift` pip packages, among others - you can do so in one shot by running the following command:

```bash
python3 -m pip install --upgrade -r requirements.txt
```

### One-time | Installing Ansible Collections

In order to run this Playbook you'll need to have the needed Ansible Collections already installed - you can do so easily by running the following command:

```bash
ansible-galaxy collection install -r collections/requirements.yml
```

### Modify the Variables files

- Copy `example_vars/cluster-config.yaml` to the working directory, ideally with a prefix of the cluster name - modify as needed.

```bash
ls example_vars/cluster-config-*
cp example_vars/cluster-config-selected.yaml CLUSTER_NAME.cluster-config.yaml
```

- Copy the other relevant files from `example_vars/` to `vars/` to auto-load them - or the working directory to manually include them - and modify as you see fit, such as those for infrastructure credentials.
```
cp example_vars/credentials-infrastructure.yaml  credentials-infrastructure.yaml
```

### Running the Playbook

With the needed variables altered, you can run the Playbook with the following command:

```bash
ansible-playbook -e "@CLUSTER_NAME.cluster-config.yaml" -e "@credentials-infrastructure.yaml" bootstrap.yaml
```

### Destroying the Cluster

If you are done with the cluster or some error occurred you can quickly delete it from your infrastructure environments, the Assisted Installer Service, and the local assets that were generated during creation:

```bash
ansible-playbook -e "@CLUSTER_NAME.cluster-config.yaml" -e "@credentials-infrastructure.yaml" destroy.yaml
```
