.DEFAULT_GOAL := build

GIT_URL := https://github.com/kenmoini/ocp4-ai-svc-universal.git
TAG := 0.1.0 
INSTALL_PATH = ~/.ansible-navigator.yml
SOURCE_FILE = ~/ocp4-ai-svc-universal/ansible-navigator/release-ansible-navigator.yml

INSTALL_ANSIBLE_NAVIGATOR := pip3 install ansible-navigator
BUILD_CMD := tag=$(TAG) && ansible-builder build -f execution-environment.yml -t ocp4-ai-svc-universal:$${tag} -v 3
COPY_NAVIGATOR_CMD := cp $(SOURCE_FILE) $(INSTALL_PATH)
PODMAN_LOGIN := podman login registry.redhat.io
LIST_INVENTORY_CMD := ansible-navigator inventory --list -m stdout
REMOVE_BAD_BUILDS := podman rmi $$(podman images | grep "<none>" | awk '{print $$3}')
REMOVE_IMAGES := podman rmi $$(podman images | grep "ocp4-ai-svc-universal" | awk '{print $$3}')

.PHONY: install-ansible-navigator
install-ansible-navigator:
	$(INSTALL_ANSIBLE_NAVIGATOR)

.PHONY: build-image
build-image:
	$(BUILD_CMD)
	
.PHONY: podman-login
podman-login:
	$(PODMAN_LOGIN)

.PHONY: copy-navigator
copy-navigator:
	$(COPY_NAVIGATOR_CMD)

.PHONY: list-inventory
list-inventory:
	$(LIST_INVENTORY_CMD)

.PHONY: remove-bad-builds
remove-bad-builds:
	$(REMOVE_BAD_BUILDS)

.PHONY: remove-images
remove-images:
	$(REMOVE_IMAGES)