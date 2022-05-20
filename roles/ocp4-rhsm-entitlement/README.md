Red Hat Subscription Manager Entitlement
=========

Applies a RHSM Entitlement Certificate to the OpenShift cluster in order to provide entitled builds from traditional RH repos.

Requirements
------------

An OpenShift cluster, already logged in before the Role is initiated

Role Variables
--------------

There is a required variable, `entitlementPEM` - this should be the contents of your Entitlement PEM certificate.  You can paste it in, or otherwise provide it as a file lookup: `entitlementPEM: "{{ lookup('file', '/path/to/entitlement.pem') }}"`

Example Playbook
----------------
```yaml
- hosts: localhost
  vars:
    entitlementPEM: "{{ lookup('file', '/path/to/entitlement.pem') }}"
  tasks:
    - name: Run old fasioned oc CLI commands
      block:
      - name: Log into the cluster
        shell:
          cmd: "oc login {{ cluster_api_url }} --password=\"{{ cluster_kubeadmin_password }}\" --username=\"{{ cluster_kubeadmin_username }}\" --insecure-skip-tls-verify=true"
        no_log: true
        register: cluster_auth_status
        until: (cluster_auth_status.rc == 0)
        retries: 120
        delay: 20

      - name: Deploy RHSM Entitlement
        include_role:
          name: ocp-rhsm-entitlement

      always:
      - name: Log out of the cluster
        shell:
          cmd: oc logout
```

License
-------

BSD

Author Information
------------------

Ken Moini - www.kenmoini.com