# Using in Ansible Tower/Controller

In case you'd like to wrap a GUI around this repo, there are some decently easy ways to do so.

## Using Site Configs

Please don't pipe in hundreds of lines of YAML and secrets in via runtime execution.  Use Site Configs.

Read the adjacent document in this folder titled `using-site-configs.md`.

## Configuring Tower

1. Create an **Execution Environment** in Tower - you can use the upstrema image `quay.io/kenmoini/ocp4-ai-svc-universal-ee:latest`
2. Create a **Project** in Tower pointing to it.  Configure it to use the EE.
3. Create an Inventory/Host - it's just a `localhost` inventory for the EE with the following Host vars:

```yaml
---
ansible_connection: local
ansible_python_interpreter: '{{ ansible_playbook_python }}'
# optional:
# ansible_ssh_common_args: '-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ForwardAgent=yes'
```

6. Create a **Job Template**, select the Project, EE, and the Inventory.  Provide it a Vault-type Credential to decrypt your vaulted variables.  Give it the default vars of:

```yaml
---
use_site_configs: true

# overrides
# cluster_version: 4.11
```

Check the box for Privilege Escalation.

7. Once the Job Template is saved, give it a **Survey** - ask for the `site_config_name` variable as a text/string box.

### Libvirt Targets

If you're using Libvirt/KVM hosts as infrastructure providers, then you likely need to use qemu+ssh to connect to the host, and probably with SSH Keys.

In a Tower/Controller context this is challenging - the best way I've figured to use it is via mounting a directory from the host/K8s Secret to the EE when running.

1. On the Tower/Controller host, make a directory: `mkdir -p /var/run/awx-secrets/.ssh/`
2. For Tower/Controller in a VM, navigate to **Settings > Job Settings**.  Add an entry to **Paths to expose to isolated jobs**: `"/var/run/awx-secrets:/var/run/awx-secrets:O"`.  Make sure **Expose host paths for Container Groups** is enabled.
3. Copy the needed secrets to that directory and reference them in your `provider.credential.libvirt_ssh_key_path`
