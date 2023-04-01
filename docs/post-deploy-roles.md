# Post Deployment Ansible Roles

There are often a few things you may want to bootstrap right after a cluster has been installed, such as API or Application Ingress certificates, Identity Providers, and so on.

There are a few included post-deployment roles that can be applied to your cluster after it has been installed.

## Defining the Post Deployment Roles

To enable these extra post-deployment roles, in your cluster configuration YAML define the following extra variable `extra_roles`:

```yaml
################################################## Extra Post-Provisioning Roles
# [optional] extra_roles: name of roles to run after cluster provisioning

extra_roles:
  - ocp4-matrix-login
  - ocp4-mario-game
```

The items in that list are from the names of the Ansible Roles in the `roles/` folder.  They include:

- `ocp4-certificates` - Configure the Cluster-wide Additional Trust CA Bundle and API/Application Certificates
- `ocp4-deploy-nutanix-csi` - Deploy the Nutanix CSI (really only when deploying to NTNX clusters)
- `ocp4-idp` - Configure Identity Providers, supports Google OAuth, LDAP, and ActiveDirectory
- `ocp4-mario-game` - A fun in-browser "Mario" game, simple deployment test
- `ocp4-ntp-configuration` - Configure NTP Pools/Servers and Chrony Config
- `ocp4-red-matrix-login` - Get some red drippy matrix slickness on your login screen
- `ocp4-rhsm-entitlement` - Provide Red Hat Subscription Management entitlements to the cluster for entitled image builds.  Not really needed anymore with Simple Content Access.

---

## ocp4-certificates

In order to configure certificates you'll need to pass in some configuration:

```yaml
#######################################################################################################################
## ocp4-certificates role needed variables
#######################################################################################################################

## API Load Balancer TLS Certificate & Key
cluster_api_lb_tls_crt: SOME_VAULTED_THING
cluster_api_lb_tls_key: SOME_OTHER_VAULTED_THING_OR_YA_KNOW_SLURP_IT_WITH_A_PRE_WORKFLOW_JOB_I_GUESS

## Application Ingress Load Balancer TLS Certificate & Key
cluster_app_lb_tls_crt: "{{ lookup('file', '/opt/core-ocp.lab.kemo.network.full-chain.cert.pem') }}"
cluster_app_lb_tls_key: "{{ lookup('file', '/opt/core-ocp.lab.kemo.network.key.pem') }}"

## additionalTrustBundle must also be set for any additional Root CAs if not part of the standard ca-certificates bundle
additionalTrustBundle: |
  -----BEGIN CERTIFICATE-----
  MIIG3TCCBMWgAwIBAgIUJSmf6Ooxg8uIwfFlHQYFQl5KMSYwDQYJKoZIhvcNAQEL
  BQAwgcMxIzAhBgkqhkiG9w0BCQEWFG5hLXNlLXJ0b0ByZWRoYXQuY29tMQswCQYD
  REPLACE
  WITH
  YOUR
  OWN
  ROOT
  CA
  S5kIfhw8FM52x6RHCwRicArO8HSTCf4ueEkFL7yj5xSI
  -----END CERTIFICATE-----
  -----BEGIN CERTIFICATE-----
  MIIGqzCCBJOgAwIBAgIUKMZCYZxHomZOUFLz8j0/ItBY/3cwDQYJKoZIhvcNAQEL
  REPLACE
  WITH
  ANOTHER
  ROOT
  CA
  IF
  YOU
  WANT
  LSMk1f3L54UjG+iMyolALyCvpibGD6g6PRMp8UTStZatPJDzT2/JbFu9mIhU5V4g
  zYML3t12ZU8JGpxxfUk2ObjKbixfSwSmTcWb+s8kgg==
  -----END CERTIFICATE-----
```

---

## ocp4-deploy-nutanix-csi

If you're running with nodes running on Nutanix and only on Nutanix, you can install the CSi post-install to leverage the underlying storage for Block (RWO) and Filesystem (RWO/RWX) storage.

Enable the role by adding it to the list, optionally maybe enable the StorageClasses by overriding the variables below:

```yaml
# Defaults for the operator install and StorageClass config
operator_namespace: ntnx-system
secret_name: ntnx-secret

# Whether or not to deploy the StorageClasses too
nutanix_csi_deploy_files_storageclass: false
nutanix_csi_deploy_volumes_storageclass: false

# This MachineConfig is needed for Volumes, if not already set by injected_manifests during install
nutanix_csi_deploy_iscsid_machineconfig: true

## Volumes StorageClass Defaults
nutanix_csi_volumes_filesystem_type: ext4
nutanix_csi_volumes_flashmode: false

# File StorageClass Defaults
nutanix_csi_deploy_files_storageclass_selinux_patch: true
```

---

## ocp4-idp

This role will configure your identity providers on the cluster.  Supports Google OAuth, LDAP, and ActiveDirectory.  See the `examples/role-vars.ocp4-idp.yaml` file for more information and examples (*there's a lot of YAML)*.

---

## ocp4-mario-game

There are no required variables in order to use this role.

Optional variables and their defaults:

```yaml
mario_project_namespace: infinite-mario
```

---

## ocp4-ntp-configuration

In order to configure chrony on the nodes with NTP servers of your own, set the following variables after adding the role to the list of `extra_roles`:

```yaml
ntp_sources:
  - type: server
    address: 192.168.42.14
  # using servers and pools are mutually exclusive
#  - type: pool
#    address: 0.rhel.pool.ntp.org
```

---

## ocp4-red-matrix-login

No variables are needed - just wait for some sick drippy red text on the login screen...unless you don't want them to be red.  In that case, set these optional default variables:

```yaml
dripping_text_color: "#a30000"

dripping_text_font_size: 10
```

---

## ocp4-rhsm-entitlement

This isn't really needed now that OCP has SCA, but in case you want to [extract your entitlement certificate](https://examples.openshift.pub/build/entitled/), you can apply the PEM with this variable:

```yaml
# vars for ocp4-rhsm-entitlement
entitlementPEM: "{{ lookup('file', '/mnt/remoteWork/rh-entitlement.pem') }}"
```
