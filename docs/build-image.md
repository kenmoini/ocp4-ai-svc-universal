# Development notes for building the ansible-navigator image

The 'ocp4-ai-svc-universal' project is a comprehensive solution that guides users on deploying the OpenShift Assisted installer to VMware infrastructure. This deployment methodology is particularly suitable for static environments where a consistent setup is required. By leveraging the power of Ansible Navigator, the project automates the entire deployment process, simplifying the configuration and provisioning of the Assisted installer. With 'ocp4-ai-svc-universal', users can easily set up OpenShift clusters on VMware, taking advantage of the efficiency and reliability of the Assisted installer, while benefiting from the automation capabilities offered by Ansible Navigator. This solution streamlines the deployment workflow, enabling users to quickly and consistently deploy OpenShift in their VMware environments.

## Getting Started

**Install the following packages**
```
$ sudo dnf install git vim unzip wget bind-utils python3-pip tar util-linux-user  gcc python3-devel podman ansible-core make  -y
```

### Red Hat Registry Pull Secret

To deploy OpenShift in a connected environment, you need to provide a registry pull secret.  Get yours from here: https://cloud.redhat.com/openshift/install/pull-secret

It's suggested to use the Copy-to-Clipboard button to copy the registry pull secret to the clipboard.  Then, paste it into a file somewhere like `~/ocp-pull-secret` - make sure there is no white space in the JSON structure.

### Red Hat API Offline Token

To use the Red Hat hosted Assisted Install Service, you need to provide a Red Hat API Offline Token.  Get yours from here: https://access.redhat.com/management/api

Take the token and store it in a file somewhere like `~/rh-api-offline-token`

**Git Clone Repo**
```
git clone https://github.com/kenmoini/ocp4-ai-svc-universal.git

cd $HOME/ocp4-ai-svc-universal/
```

**Create Inveentory**
```
export INVENTORY=vmc # on demo.redhat.com $GUID
cd $HOME/ocp4-ai-svc-universal
mkdir -p inventories/${INVENTORY}/group_vars
mkdir -p inventories/${INVENTORY}/group_vars/control
cp example_vars/cluster-config-vmware-demo.yaml inventories/${INVENTORY}/group_vars/all.yaml
```

**Add hosts file**
```
control_user=admin
control_host=$(hostname -I | awk '{print $1}')
echo "[control]" > inventories/${INVENTORY}/hosts
echo "control ansible_host=${control_host} ansible_user=${control_user}" >> inventories/${INVENTORY}/hosts
```

**Update the variables**
```
./configure-vars.sh
```

**Test inventory**
```
 ansible-navigator inventory --list -m stdout --vault-password-file $HOME/.vault_password
```

**Create credentials file**
```
cat >vars/credentials-infrastructure.yaml<<EOF
---
infrastructure_providers:
  ## vSphere Infrastructure Provider
  - name: labVMWare
    type: vsphere
    credentials:
      vcenter_username: username
      vcenter_password: XXXXXXXXX
      vcenter_hostname: testing
      vcenter_verify_ssl: false
    configuration:
      vcenter_datacenter: XXXXX
      vcenter_cluster: XXXXX
      vcenter_datastore: XXXXX
      vcenter_network: XXXXX
      vcenter_iso_dir: ISOs  # use isos/$GUID for demo.redhat.com
EOF
```

**Configure SSH**
```
IP_ADDRESS=$(hostname -I | awk '{print $1}')
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
ssh-copy-id $USER@${IP_ADDRESS}
```

**Install Ansible Navigator**
```bash
make install-ansible-navigator
```

**If you use Red Hat Enterprise Linux with an active Subscription, you might have to lo log into the registry first:**

```bash
make podman-login
```

**Create Ansible navigator config file**
```
cat >~/.ansible-navigator.yml<<EOF
---
ansible-navigator:
  ansible:
    inventory:
      entries:
      - /home/$USER/ocp4-ai-svc-universal/inventories/${INVENTORY}
      - /home/$USER/ocp4-ai-svc-universal/vars
  execution-environment:
    container-engine: podman
    enabled: true
    environment-variables:
      pass:
      - USER
    image: localhost/ocp4-ai-svc-universal:0.1.0 
    pull:
      policy: missing
  logging:
    append: true
    file: /tmp/navigator/ansible-navigator.log
    level: debug
  playbook-artifact:
    enable: false
EOF
```
**Setup ansible vault**
```
curl -OL https://gist.githubusercontent.com/tosin2013/022841d90216df8617244ab6d6aceaf8/raw/92400b9e459351d204feb67b985c08df6477d7fa/ansible_vault_setup.sh
chmod +x ansible_vault_setup.sh
./ansible_vault_setup.sh
```

**Build the image:**
```bash
make build-image
```

**Validate Inventory**
```
 ansible-navigator inventory --list -m stdout --vault-password-file $HOME/.vault_password
```

### Running the Playbook on standard VMWARE instance
```
$ ansible-navigator run bootstrap.yaml  --vault-password-file $HOME/.vault_password -m stdout 
```

### On VMC demo.redhat.com
```
$ ansible-navigator run bootstrap.yaml  --vault-password-file $HOME/.vault_password -m stdout  --skip-tags "vmware_create_folder,vmware_create_iso_directory" 
```

### Navigate to console.redhat.com to view your cluster details
* https://console.redhat.com/openshift/

### Destroying the Cluster
```
 ansible-navigator run destroy.yaml  --vault-password-file $HOME/.vault_password -m stdout  --skip-tags vmware_create_folder
```