# Packer vSphere Templates

This repository contains Packer templates for building clean base VM images for VMware vSphere environments. The templates create minimal, standardized images with LVM partitioning and an Ansible service account for post-deployment configuration.

## Features

- **Multiple OS Support**: Debian 12, Debian 13, Ubuntu 22.04, Ubuntu 24.04
- **VMware vSphere Integration**: Native vSphere support with VMware Tools
- **LVM Partitioning**: 64GB disk with logical volume management
- **Ansible Ready**: Pre-configured ansible service account with SSH key authentication
- **Clean Base Images**: Minimal installations optimized for template use
- **Automated Builds**: GitLab CI/CD pipeline with validation and build stages

## Directory Structure

```
packer-vsphere-templates/
├── builds/                          # Packer build definitions
│   ├── debian-12.pkr.hcl
│   ├── debian-13.pkr.hcl
│   ├── ubuntu-22.04.pkr.hcl
│   └── ubuntu-24.04.pkr.hcl
├── configs/                         # OS-specific configurations
│   ├── debian-12/
│   │   ├── preseed.cfg             # Automated installation config
│   │   └── variables.pkrvars.hcl   # OS-specific variables
│   ├── debian-13/
│   ├── ubuntu-22.04/
│   │   ├── user-data               # Cloud-init configuration
│   │   ├── meta-data               # Cloud-init metadata
│   │   └── variables.pkrvars.hcl
│   └── ubuntu-24.04/
├── scripts/                         # Provisioning scripts
│   ├── common/                     # Shared scripts for all OS
│   │   ├── cleanup.sh
│   │   ├── configure-lvm.sh
│   │   ├── install-vmware-tools.sh
│   │   └── setup-ansible-user.sh
│   ├── debian/
│   │   └── setup.sh
│   └── ubuntu/
│       └── setup.sh
├── variables.pkr.hcl               # Global variables
├── locals.pkr.hcl                 # Local values and computed settings
├── Makefile                        # Build automation
├── .gitlab-ci.yml                  # CI/CD pipeline
├── .env.example                    # Environment variables template
└── .gitignore                      # Git ignore rules
```

## Prerequisites

### Required Software

- [Packer](https://www.packer.io/downloads) >= 1.9.0
- VMware vSphere environment access
- GNU Make (optional, for Makefile usage)

### Environment Variables

Copy `.env.example` to `.env` and configure the following variables:

```bash
# vCenter Connection
VCENTER_SERVER=vcenter.example.com
VCENTER_USER=administrator@vsphere.local
VCENTER_PASSWORD=your-password
VCENTER_DATACENTER=Datacenter1
VCENTER_CLUSTER=Cluster1
VCENTER_DATASTORE=datastore1
VCENTER_NETWORK="VM Network"
VCENTER_FOLDER=Templates
VCENTER_RESOURCE_POOL=""

# Ansible Configuration
ANSIBLE_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2E..."
ANSIBLE_USER_PASSWORD=secure-password
```

## Quick Start

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd packer-vsphere-templates
   ```

2. **Configure environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your vCenter details and Ansible public key
   source .env
   ```

3. **Initialize Packer**:
   ```bash
   make init
   ```

4. **Validate templates**:
   ```bash
   make validate
   ```

5. **Build a specific template**:
   ```bash
   make build-ubuntu-22.04
   # or
   make build-debian-12
   ```

6. **Build all templates**:
   ```bash
   make build-all
   ```

## Available Make Targets

| Target | Description |
|--------|-------------|
| `help` | Show available targets |
| `validate` | Validate all Packer templates |
| `build-all` | Build all VM templates |
| `build-debian-12` | Build Debian 12 template |
| `build-debian-13` | Build Debian 13 template |
| `build-ubuntu-22.04` | Build Ubuntu 22.04 template |
| `build-ubuntu-24.04` | Build Ubuntu 24.04 template |
| `fmt` | Format Packer configuration files |
| `init` | Initialize Packer plugins |
| `clean` | Clean up temporary files |
| `check-env` | Verify required environment variables |
| `install-packer` | Install Packer (macOS with brew) |

## Manual Build Commands

If you prefer to use Packer directly:

```bash
# Validate a template
packer validate builds/ubuntu-22.04.pkr.hcl

# Build a specific template
packer build -var-file="configs/ubuntu-22.04/variables.pkrvars.hcl" builds/ubuntu-22.04.pkr.hcl

# Build with specific variables
packer build \\
  -var="vcenter_server=vcenter.example.com" \\
  -var="vcenter_user=admin" \\
  -var="vcenter_password=password" \\
  builds/ubuntu-22.04.pkr.hcl
```

## Template Configuration

### VM Specifications

All templates are configured with:
- **CPU**: 2 cores
- **RAM**: 4GB
- **Disk**: 64GB (thin provisioned)
- **Network**: vmxnet3
- **Firmware**: EFI
- **Controller**: PVSCSI

### Partitioning Scheme

The templates use LVM with the following layout:
- `/boot`: 2GB (ext4)
- `/` (root): 20GB (LVM, ext4)
- `swap`: 4GB (LVM)
- `/home`: Remaining space (LVM, ext4)

### Installed Packages

Base packages installed on all templates:
- openssh-server
- curl, wget
- sudo
- vim, htop, tree
- git, rsync
- lvm2, parted
- cloud-init
- python3, python3-pip
- VMware Tools (open-vm-tools)

## Ansible Integration

The templates create an ansible user with:
- Passwordless sudo access
- SSH key authentication (using `ANSIBLE_PUBLIC_KEY`)
- Home directory at `/home/ansible`

Post-deployment, you can connect using:
```bash
ssh -i ~/.ssh/ansible_key ansible@vm-ip-address
```

## CI/CD Pipeline

The GitLab CI pipeline includes:

### Validation Stage
- Validates all Packer templates
- Checks for syntax errors
- Runs on merge requests and main branch

### Build Stage
- Builds templates when files change
- Manual triggers available
- Artifacts stored for 1 week
- Individual jobs for each OS

### Usage in GitLab

Set the following CI/CD variables in your GitLab project:
- `VCENTER_SERVER`
- `VCENTER_USER`
- `VCENTER_PASSWORD`
- `VCENTER_DATACENTER`
- `VCENTER_CLUSTER`
- `VCENTER_DATASTORE`
- `VCENTER_NETWORK`
- `ANSIBLE_PUBLIC_KEY`
- `ANSIBLE_USER_PASSWORD`

## Customization

### Adding New OS Versions

1. Create a new directory in `configs/`
2. Add appropriate configuration files (preseed.cfg for Debian, user-data/meta-data for Ubuntu)
3. Create a new build file in `builds/`
4. Add the OS configuration to `locals.pkr.hcl`
5. Update the Makefile and GitLab CI pipeline

### Modifying VM Specifications

Edit the variables in `variables.pkr.hcl` or override them in the OS-specific `variables.pkrvars.hcl` files:

```hcl
vm_cpu_count = 4
vm_memory_mb = 8192
vm_disk_size_gb = 100
```

### Custom Provisioning Scripts

Add custom scripts to the appropriate directory:
- `scripts/common/` - Runs on all OS types
- `scripts/debian/` - Debian-specific scripts
- `scripts/ubuntu/` - Ubuntu-specific scripts

Update the provisioner configuration in `locals.pkr.hcl` to include your scripts.

## Security Considerations

- **No Security Hardening**: Templates are intentionally minimal with no security hardening applied
- **Default Passwords**: Root password is set to "packer" during build and should be changed post-deployment
- **SSH Access**: Root SSH access is enabled for build process
- **Ansible User**: Has passwordless sudo access for automation

Security hardening should be applied post-deployment using Ansible playbooks or other configuration management tools.

## Troubleshooting

### Common Issues

1. **Build Timeouts**: Increase timeout values in build files if downloads are slow
2. **Network Issues**: Ensure vCenter network allows DHCP and internet access
3. **ISO Download Failures**: Check internet connectivity and ISO URLs
4. **vCenter Permission Issues**: Ensure the vCenter user has appropriate permissions

### Debug Mode

Enable debug logging:
```bash
export PACKER_LOG=1
export PACKER_LOG_PATH=./packer.log
packer build ...
```

### Template Validation

Always validate templates before building:
```bash
make validate
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `make validate`
5. Submit a pull request

## License

[Specify your license here]

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Packer documentation
3. Open an issue in this repository