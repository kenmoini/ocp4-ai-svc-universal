# Development notes for building the ansible-navigator image


## Getting Started


**Git Clone Repo**
```
git clone https://github.com/kenmoini/ocp4-ai-svc-universal.git

cd $HOME/ocp4-ai-svc-universal/
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
      - /home/$USER/ocp4-ai-svc-universal/${INVENTORY}
  execution-environment:
    container-engine: podman
    enabled: true
    environment-variables:
      pass:
      - USER
    image:  localhost/ocp4-ai-svc-universal-ee:0.1.0
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

**Add hosts file**
```
# control_user=admin
# control_host=$(hostname -I | awk '{print $1}')
echo "[control]" > inventories/${INVENTORY}/hosts
echo "control ansible_host=${control_host} ansible_user=${control_user}" >> inventories/${INVENTORY}/hosts
```

**Build the image:**
```bash
make build-image
```