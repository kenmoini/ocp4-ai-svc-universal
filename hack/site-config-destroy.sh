#!/bin/bash

VAULT_ARGS=""

# Check to see if there was an argument passed for the cluster config
if [ -z "$1" ]; then
    echo "No site config folder specified"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $SCRIPT_DIR/..

# Check to see if the site config folder exists
if [ ! -d "site-config/${1}" ]; then
    echo "Site config ${1} does not exist"
    exit 1
fi

if [ ! -z "$2" ]; then
    if [ -f "$2" ]; then
        VAULT_ARGS="--vault-password-file ${2}"
    fi
fi

ansible-playbook -e use_site_configs='true' -e site_config_name="${1}" ${VAULT_ARGS} destroy.yaml