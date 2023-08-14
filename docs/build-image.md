# Deploy The Assisted Installer Via Ansible Navigator

The 'ocp4-ai-svc-universal' project is a comprehensive solution that guides users on deploying the OpenShift Assisted installer to VMware infrastructure. This deployment methodology is particularly suitable for static environments where a consistent setup is required. By leveraging the power of Ansible Navigator, the project automates the entire deployment process, simplifying the configuration and provisioning of the Assisted installer. With 'ocp4-ai-svc-universal', users can easily set up OpenShift clusters on VMware, taking advantage of the efficiency and reliability of the Assisted installer, while benefiting from the automation capabilities offered by Ansible Navigator. This solution streamlines the deployment workflow, enabling users to quickly and consistently deploy OpenShift in their VMware environments.

## Prerequisites
When deploying from demo.redhat.com you will need to have the following:
- Fork https://github.com/Red-Hat-SE-RTO/ocp4-ai-svc-universal repo
- Copy ssh key to bastion host using the link - [How to use GitHub Action to Run SSH Commands](https://medium.com/@tcij1013/how-to-use-github-action-to-run-ssh-commands-609df2a88ac3)
- Update the bastion host to use ansible navigator 
*Replace hostname with bastion host*
![20230624122814](https://i.imgur.com/Gi2eLfJ.png)

## Getting Started
**ssh into bastion host**
```
ssh user@example.com
```

**Install the following packages**
```
$ sudo dnf install git vim unzip wget bind-utils python3-pip tar util-linux-user  gcc python3-devel podman make  -y
```

### Red Hat Registry Pull Secret

To deploy OpenShift in a connected environment, you need to provide a registry pull secret.  Get yours from here: https://cloud.redhat.com/openshift/install/pull-secret

It's suggested to use the Copy-to-Clipboard button to copy the registry pull secret to the clipboard.  Then, paste it into a file somewhere like `~/ocp-pull-secret` - make sure there is no white space in the JSON structure.

### Red Hat API Offline Token

To use the Red Hat hosted Assisted Install Service, you need to provide a Red Hat API Offline Token.  Get yours from here: https://access.redhat.com/management/api

Take the token and store it in a file somewhere like `~/rh-api-offline-token`

**Git Clone Repo**
*if pipeline was not ran*
```
git clone https://github.com/yourrepo/ocp4-ai-svc-universal.git 

cd $HOME/ocp4-ai-svc-universal/
```

**Update the variables**  
See [Configure Vars Workflow Document](configure-vars.md) for more details

**Create Inventory**
```
./configure-vars.sh -s 192.168.10.0/24 -o 192.168.10 -a 192.168.10.10 -e 192.168.10.11  -d example.com
```

**Add hosts file**
```
control_user=${USER}
control_host=$(hostname -I | awk '{print $1}')
echo "[control]" > inventories/${INVENTORY}/hosts
echo "control ansible_host=${control_host} ansible_user=${control_user}" >> inventories/${INVENTORY}/hosts
```

**Create credentials file**
*Optional Still Testing [configure-creds.py](../configure-creds.py)*
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
vi vars/credentials-infrastructure.yaml
```

**Configure SSH**
```
IP_ADDRESS=$(hostname -I | awk '{print $1}')
ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
ssh-copy-id $USER@${IP_ADDRESS}
```

**Install Ansible Navigator**
*if pipeline was not ran*
```bash
make install-ansible-navigator
```

**If you use Red Hat Enterprise Linux with an active Subscription, you might have to lo log into the registry first:**
*Optional*
```bash
make podman-login
```

**Create Ansible navigator config file**
```
export INVENTORY=$GUID
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
**Create iso/$GUID folder**
![20230624122604](https://i.imgur.com/l7N4exD.png)
```
$ ansible-navigator run bootstrap.yaml  --vault-password-file $HOME/.vault_password -m stdout  --skip-tags "vmware_create_folder,vmware_create_iso_directory" 
```

### Navigate to console.redhat.com to view your cluster details
* https://console.redhat.com/openshift/

### Destroying the Cluster
```
$ ansible-navigator run destroy.yaml  --vault-password-file $HOME/.vault_password -m stdout  --skip-tags  "vmware_create_folder,vmware_create_iso_directory" 
```
