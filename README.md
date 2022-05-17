# OpenShift Assisted Installer Service, Universal Deployer

This set of resources handles an idempotent way to deploy OpenShift via the Assisted Installer Service to any number of infrastructure platforms.

## Operations

The following tasks performed by the different Playbooks are:

### bootstrap.yaml

- Preflight for binaries, create asset generation directory, set HTTP Headers & Authentication
- Preflight checks for supported OpenShift versions on the Assisted Installer Service
- TODO: Preflight to do connectivity tests to infrastructure platforms
- Query the AI Svc, check for existing cluster with the same name, set facts if so


## Prerequisites

- Ansible Automation - `python3 -m pip install ansible`
- cURL - `dnf install curl`
- Git - `dnf install git`
- jq - `dnf install jq`

### One-time | Installing oc

There are a few Ansible Tasks that use the `command` module to execute commands best/easiest serviced by the `oc` binary - thusly, `oc` needs to be available in the system path

```bash
## Create a binary directory if needed
sudo mkdir -p /usr/local/bin
sudo echo 'export PATH="/usr/local/bin:$PATH"' > /etc/profile.d/usrlibbin.sh
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
ansible-galaxy collection install -r requirements.yml
```

### Modify the Variables files

- Copy `example_vars/cluster-config.yaml` to the working directory, ideally with a prefix of the cluster name - modify as needed.

```bash
cp example_vars/cluster-config.yaml CLUSTER_NAME.cluster-config.yaml
```

- Copy the other relevant files from `example_vars/` to `vars/` and modify as you see fit, such as those for infrastructure credentials.

### Running the Playbook

With the needed variables altered, you can run the Playbook with the following command:

```bash
ansible-playbook -e "@cluster-name.cluster-config.yaml" bootstrap.yaml
```

### Destroying the Cluster

If you are done with the cluster or some error occured you can quickly delete it from the Nutanix environment, the Assisted Installer Service, and the local assets:

```bash
ansible-playbook -e "@my-ocp-cluster.cluster-config.yaml" destroy.yaml
```
