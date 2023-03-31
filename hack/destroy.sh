#!/bin/bash

# Check to see if there was an argument passed for the cluster config
if [ -z "$1" ]; then
    echo "No cluster config file specified"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $SCRIPT_DIR/..

ansible-playbook -e "@credentials-infrastructure.yaml" -e "@${1}" destroy.yaml