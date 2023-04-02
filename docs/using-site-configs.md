# Using Site Configs

Duing Job/Playbook execution you need to either dump in a bunch of variables during runtime, or you can leverage **Site Configs** - *and using site configs is better*.

A Site Config defines a cluster essentially - just make a folder under `site-config`, you can name it whatever but I like sticking to the `cluster_name.base_domain` format.

In that folder, you can store any number of YAML files - during executiong they'll be dynamically loaded and executed.

## How To

1. Create a **Fork** of this repository
2. Add your **Site Configs** for your clusters.  You can copy them from the `example_vars/site-config` directory:

```bash
# Create a new Site Config directory
mkdir site-config/my-cluster.example.com

# Copy the example files
cp example_vars/site-config/* site-config/my-cluster.example.com/
```

3. Make sure to **Vault** your secrets:

```bash
# Create a new variable file to encrypt
ansible-vault create site-config/my-cluster.example.com/some-secret-variables.yml

# Encrypt an existing file
ansible-vault encrypt site-config/cluster.example.com/vault-idp.yml

# Edit a vaulted file
ansible-vault edit site-config/cluster.example.com/vault-idp.yml
```

> Pay attention to your secret variables and make sure they're vaulted before commiting them to SCM.

4. `git add/commit/push` the site-config to leverage this with GitOps and/or in Tower/Controller.

---

## Local Execution

In case you want to use site configs locally, there's a handy dandy helper script to do so - you just have to pass it the Site Config name and the Ansible Vault password file to use:

```bash
# Create a vault password file
cat > ~/.ansible-vault-pw <<EOF
#!/bin/bash
echo securePassw0rd
exit 0
EOF

# Run the helper script to create a cluster
./hack/site-config-create.sh my-cluster.example.com ~/.ansible-vault-pw

# Run the helper script to destroy a cluster
./hack/site-config-destroy.sh my-cluster.example.com ~/.ansible-vault-pw
```

## Tower/Controller Execution

Read `using-in-tower.md`
