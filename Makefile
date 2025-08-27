.PHONY: help validate build-all build-debian-12 build-debian-13 build-ubuntu-22.04 build-ubuntu-24.04 clean

PACKER := packer
CONFIG_DIR := configs
BUILD_DIR := builds

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-20s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

validate: ## Validate all Packer templates
	@echo "Validating Packer templates..."
	@$(PACKER) validate $(BUILD_DIR)/debian-12.pkr.hcl
	@$(PACKER) validate $(BUILD_DIR)/debian-13.pkr.hcl
	@$(PACKER) validate $(BUILD_DIR)/ubuntu-22.04.pkr.hcl
	@$(PACKER) validate $(BUILD_DIR)/ubuntu-24.04.pkr.hcl
	@echo "All templates are valid!"

build-all: validate ## Build all VM templates
	@echo "Building all VM templates..."
	@$(MAKE) build-debian-12
	@$(MAKE) build-debian-13
	@$(MAKE) build-ubuntu-22.04
	@$(MAKE) build-ubuntu-24.04

build-debian-12: ## Build Debian 12 template
	@echo "Building Debian 12 template..."
	@$(PACKER) build -var-file="$(CONFIG_DIR)/debian-12/variables.pkrvars.hcl" $(BUILD_DIR)/debian-12.pkr.hcl

build-debian-13: ## Build Debian 13 template
	@echo "Building Debian 13 template..."
	@$(PACKER) build -var-file="$(CONFIG_DIR)/debian-13/variables.pkrvars.hcl" $(BUILD_DIR)/debian-13.pkr.hcl

build-ubuntu-22.04: ## Build Ubuntu 22.04 template
	@echo "Building Ubuntu 22.04 template..."
	@$(PACKER) build -var-file="$(CONFIG_DIR)/ubuntu-22.04/variables.pkrvars.hcl" $(BUILD_DIR)/ubuntu-22.04.pkr.hcl

build-ubuntu-24.04: ## Build Ubuntu 24.04 template
	@echo "Building Ubuntu 24.04 template..."
	@$(PACKER) build -var-file="$(CONFIG_DIR)/ubuntu-24.04/variables.pkrvars.hcl" $(BUILD_DIR)/ubuntu-24.04.pkr.hcl

fmt: ## Format all Packer configuration files
	@echo "Formatting Packer configuration files..."
	@$(PACKER) fmt .

init: ## Initialize Packer (download required plugins)
	@echo "Initializing Packer..."
	@$(PACKER) init $(BUILD_DIR)/debian-12.pkr.hcl
	@$(PACKER) init $(BUILD_DIR)/debian-13.pkr.hcl
	@$(PACKER) init $(BUILD_DIR)/ubuntu-22.04.pkr.hcl
	@$(PACKER) init $(BUILD_DIR)/ubuntu-24.04.pkr.hcl

clean: ## Clean up temporary files and artifacts
	@echo "Cleaning up..."
	@rm -f packer-manifest.json
	@rm -f *.log
	@rm -rf packer_cache/
	@find . -name "*.tmp" -delete

check-env: ## Check required environment variables
	@echo "Checking required environment variables..."
	@test -n "$(VCENTER_SERVER)" || (echo "ERROR: VCENTER_SERVER not set" && exit 1)
	@test -n "$(VCENTER_USER)" || (echo "ERROR: VCENTER_USER not set" && exit 1)
	@test -n "$(VCENTER_PASSWORD)" || (echo "ERROR: VCENTER_PASSWORD not set" && exit 1)
	@test -n "$(VCENTER_DATACENTER)" || (echo "ERROR: VCENTER_DATACENTER not set" && exit 1)
	@test -n "$(VCENTER_CLUSTER)" || (echo "ERROR: VCENTER_CLUSTER not set" && exit 1)
	@test -n "$(VCENTER_DATASTORE)" || (echo "ERROR: VCENTER_DATASTORE not set" && exit 1)
	@test -n "$(VCENTER_NETWORK)" || (echo "ERROR: VCENTER_NETWORK not set" && exit 1)
	@test -n "$(ANSIBLE_PUBLIC_KEY)" || (echo "ERROR: ANSIBLE_PUBLIC_KEY not set" && exit 1)
	@test -n "$(ANSIBLE_USER_PASSWORD)" || (echo "ERROR: ANSIBLE_USER_PASSWORD not set" && exit 1)
	@echo "All required environment variables are set!"

install-packer: ## Install Packer (Linux/macOS)
	@echo "Installing Packer..."
	@command -v packer >/dev/null 2>&1 || { \
		echo "Packer not found, installing..."; \
		if command -v brew >/dev/null 2>&1; then \
			brew install packer; \
		else \
			echo "Please install Packer manually from https://www.packer.io/downloads"; \
			exit 1; \
		fi \
	}
	@$(PACKER) version