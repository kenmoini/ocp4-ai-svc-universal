#!/bin/bash

# Enable the Python 3.9 Module
sudo dnf module install -y python39
sudo dnf install -y python39 python39-devel python39-pip
sudo dnf module enable -y python39

# Make sure the Python 3.6 Module is disabled
sudo dnf module disable -y python36

# Set the default Python version to 3.9
sudo alternatives --set python /usr/bin/python3.9
sudo alternatives --set python3 /usr/bin/python3.9

# Install needed Pip modules
# - For Ansible-Navigator
curl -sSL https://raw.githubusercontent.com/ansible/ansible-navigator/main/requirements.txt | python3 -m pip install -r /dev/stdin
# - For Ansible Collections running on the bastion?
python3 -m pip install -r $HOME/device-edge-demos/hack/bastion-requirements.txt