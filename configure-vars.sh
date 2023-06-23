#!/bin/bash 
# ./script.sh -s 192.168.10.0/24 -o 192.168.10 -a 192.168.10.10 -e 192.168.10.11  -d example.com

#!/bin/bash

# Default flag values
subnet=""
oct=""
apps_ip=""
domain=""

# Parse command-line options
while getopts "s:o:a:e:d:" opt; do
  case $opt in
    s)
      subnet=$OPTARG
      ;;
    o)
      oct=$OPTARG
      ;;
    e)
      apps_ip=$OPTARG
      ;;
    a)
      api_ip=$OPTARG
      ;;
    d)
      domain=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Check if subnet flag is provided
if [ -z "$subnet" ]; then
  echo "Subnet not provided."
  exit $?
else
  echo "Subnet is set to: $subnet"
fi

# Check if oct flag is provided
if [ -z "$oct" ]; then
  echo "Octet flag not provided."
  exit $?
else
  echo "Octet flag is set to: $oct"
fi

# Check if api_ip flag is provided
if [ -z "$api_ip" ]; then
  echo "API IP flag not provided."
  exit $?
else
  echo "API IP flag is set to: $api_ip"
fi

# Check if apps_ip flag is provided
if [ -z "$apps_ip" ]; then
  echo "Apps IP flag not provided."
  exit $?
else
  echo "Apps IP flag is set to: $apps_ip"
fi

# Check if domain is provided
if [ -z "$domain" ]; then
  echo "Domain not provided."
  exit $?
else
  echo "Domain is set to: $domain"
fi

# Prompt for GUID if it is empty
if [ -z "$GUID" ]; then
  read -p "Enter the GUID/Cluster Name: " GUID
fi

export INVENTORY=vmc
cd $HOME/ocp4-ai-svc-universal
mkdir -p inventories/${INVENTORY}/group_vars
mkdir -p inventories/${INVENTORY}/group_vars/control
cp example_vars/cluster-config-vmware-demo.yaml inventories/${INVENTORY}/group_vars/all.yaml

sed -i  's/CHANGEME/'$USER'/g' inventories/${INVENTORY}/group_vars/all.yaml
sed -i 's/192.168.38.88/'${api_ip}'/g' inventories/${INVENTORY}/group_vars/all.yaml
sed -i 's/192.168.38.89/'${apps_ip}'/g' inventories/${INVENTORY}/group_vars/all.yaml
sed -i 's|192.168.38.0/24|'${subnet}'|g' inventories/${INVENTORY}/group_vars/all.yaml
sed -i 's/kemo.labs/'${domain}'/g' inventories/${INVENTORY}/group_vars/all.yaml
sed -i 's/vsphere-ocp-ha/'$GUID'/g' inventories/${INVENTORY}/group_vars/all.yaml
sed -i 's|192.168.38.|'${oct}'.|g' inventories/${INVENTORY}/group_vars/all.yaml


# Array of original MAC addresses
mac_addresses=("54:52:00:42:69:11" "54:52:00:42:69:12" "54:52:00:42:69:13" "54:52:00:42:69:14" "54:52:00:42:69:15" "54:52:00:42:69:16")

# Array of MAC address prefixes
# Define the menu prefixes
prefixes=("54:52:00:" "00:0c:29:" "00:1c:14:" "00:50:56:")

# Display the menu and prompt for prefix selection
select prefix in "${prefixes[@]}"; do
    case $REPLY in
        1)
            selected_prefix="54:52:00:"
            break
            ;;
        2)
            selected_prefix="00:0c:29:"
            break
            ;;
        3)
            selected_prefix="00:1c:14:"
            break
            ;;
        4)
            selected_prefix="00:50:56:"
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done

# Loop through the original MAC addresses
for mac_address in "${mac_addresses[@]}"; do
  # Select a random MAC address prefix from the array
  #rand_prefix=$[$RANDOM % ${#prefixes[@]}]

  # Generate a random MAC address suffix
  suffix="$( echo $[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10]:$[RANDOM%10]$[RANDOM%10] )"

  # Combine the prefix and suffix to create a new MAC address
  new_mac="${selected_prefix}$suffix"

  # Replace the original MAC address with the new MAC address in the YAML file
  sed -i 's/'"$mac_address"'/'"$new_mac"'/g' inventories/${INVENTORY}/group_vars/all.yaml
  echo  sed -i 's/'"$mac_address"'/'"$new_mac"'/g' inventories/${INVENTORY}/group_vars/all.yaml
  sleep 2s
done

echo "MAC addresses updated successfully!"

cat inventories/${INVENTORY}/group_vars/all.yaml
sleep 5s

## Prompt for deployment confirmation
#read -p "Do you want to start the deployment? (yes/no): " deploy_confirm
#if [[ $deploy_confirm == "yes" ]]; then
#  echo "Starting the deployment..."
#  ansible-navigator run bootstrap.yaml  --vault-password-file $HOME/.vault_password -m stdout  --skip-tags "vmware_create_folder,vmware_create_iso_directory" 
#else
#  echo "Deployment cancelled."
#fi
