# GitHub Actions

Supporting this repository are a set of GitHub Actions that help to maintain and release different artifacts.

- `ansible-lint-all.yml` - On PRs and Pushes to the repo, it will run `ansible-lint` on the content.  There are no dependencies.

- `base-build-deploy-ee.yml` - A reusable base workflow that is used to build Execution Environments

- `build-deploy-ee.yml` - The workflow that triggers the base with the needed inputs and secrets.  Will run on PRs/pushes to the files that affect the EE, as well as on-demand.  Requires pre-existing secrets:
  - `REGISTRY_HOSTNAME` - The hostname of the registy where you'll be pushing to, probably `quay.io`
  - `REGISTRY_USERNAME` - The username to push as
  - `REGISTRY_PASSWORD` - The password/token to authenticate with when pushing
  - `REGISTRY_PATH` - The path of your EE image to push to, in case you're using Robot Accounts in quay and actually need to push to your username or another org's path.
- `Configure Ansible Navgiator workflow` - Used to configure Ansibl Navigator on demo.redhat.com. 
Requires pre-existing secrets:
  - `USERNAME` - The username ssh in to machine as 
  - `KEY` - The public key to use to ssh in to machine
  - `PORT` - The port to ssh in to machine on
