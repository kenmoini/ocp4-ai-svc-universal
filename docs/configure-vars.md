## Configure Vars Workflow Document

Script: `configure-vars.sh`

## Description: 
This script generates a YAML inventory file for an Assited Installer Ansible Playbook.

## Inputs:

* `subnet:` The subnet for the cluster.
* `oct:` The octet for the cluster.
* `api_ip:` The IP address of the API server.
* `apps_ip:` The IP address of the applications server.
* `domain:` The domain name for the cluster.
* `GUID:` The GUID or cluster name for the inventory file.

## Outputs:

A YAML udpated inventory file named inventories/${INVENTORY}/group_vars/all.yaml.
Steps:

* Check if the `subnet`, `oct`, `api_ip`, `apps_ip`, and `domain` flags are provided.
* Prompt for the `GUID` if it is empty.
* Create a directory structure for the inventory file.
* Copy the example YAML file to the inventory file.
* Replace the placeholder values in the YAML file with the provided values.
* Replace the original MAC addresses with new MAC addresses.
* Print the updated YAML file.
* Prompt for deployment confirmation.
* Start the deployment if the user confirms.

## Dependencies:

* The `sed` command.
* The `date` command.
* The `md5sum` command.
* The `ansible-navigator` command.

## Workflow:

1. The script then prompts for the `GUID` if it is empty.
2. The script then creates a directory structure for the inventory file.
3. The script copies the example YAML file to the inventory file.
4. The script replaces the placeholder values in the YAML file with the provided values.
5. The script replaces the original MAC addresses with new MAC addresses.
6. The script prints the updated YAML file.
7. The script prompts for deployment confirmation.
8. If the user confirms, the script starts the deployment.


## Assumptions:

* The `sed`, `date`, `md5sum`, and `ansible-navigator` commands are installed.
The user has permission to create the inventory file.

## Risks:

* The script may fail if the `subnet`, `oct`, `api_ip`, `apps_ip`, or `domain` flags are not provided.
* The script may fail if the `sed`, `date`, `md5sum`, or `ansible-navigator` commands are not installed.
* The script may fail if the user does not have permission to create the inventory file.

## Mitigation Strategies:

* The user can provide the missing flags when running the script.
* The user can install the `sed`, `date`, `md5sum`, and `ansible-navigator` commands.
* The user can request permission to create the inventory file.