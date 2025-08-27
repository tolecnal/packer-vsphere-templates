locals {
  vm_name_timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
  
  common_vm_settings = {
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_user
    password                    = var.vcenter_password
    insecure_connection        = false
    datacenter                 = var.vcenter_datacenter
    cluster                    = var.vcenter_cluster
    datastore                  = var.vcenter_datastore
    folder                     = var.vcenter_folder
    resource_pool              = var.vcenter_resource_pool
    
    CPUs                       = var.vm_cpu_count
    RAM                        = var.vm_memory_mb
    RAM_reserve_all           = false
    firmware                  = var.vm_firmware
    
    disk_controller_type      = [var.vm_disk_controller_type]
    
    storage = {
      disk_size             = var.vm_disk_size_gb * 1024
      disk_thin_provisioned = var.vm_disk_thin_provisioned
    }
    
    network_adapters = {
      network      = var.vcenter_network
      network_card = var.vm_network_card
    }
    
    boot_wait    = var.boot_wait
    ssh_timeout  = var.ssh_timeout
    ssh_username = "root"
    shutdown_timeout = var.shutdown_timeout
    
    remove_cdrom = true
    convert_to_template = true
  }
  
  common_provisioners = [
    {
      type   = "shell"
      script = "scripts/common/setup-ansible-user.sh"
      environment_vars = [
        "ANSIBLE_USER=${var.ansible_user}",
        "ANSIBLE_USER_PASSWORD=${var.ansible_user_password}",
        "ANSIBLE_PUBLIC_KEY=${var.ansible_public_key}"
      ]
    },
    {
      type   = "shell"
      script = "scripts/common/install-vmware-tools.sh"
    },
    {
      type   = "shell"
      script = "scripts/common/configure-lvm.sh"
    },
    {
      type   = "shell"
      script = "scripts/common/cleanup.sh"
    }
  ]
  
  debian_12 = {
    guest_os_type    = "debian12_64Guest"
    iso_url          = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.7.0-amd64-netinst.iso"
    iso_checksum     = "sha256:911c556e90d34b5bb76fbf5509e14b28d1c3fcc79c91f5a43b52fa8e5b0b6542"
    vm_name          = "debian-12-template-${local.vm_name_timestamp}"
    boot_command = [
      "<esc><wait>",
      "install <wait>",
      "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-12/preseed.cfg <wait>",
      "debian-installer=en_US.UTF-8 <wait>",
      "auto <wait>",
      "locale=en_US.UTF-8 <wait>",
      "kbd-chooser/method=us <wait>",
      "keyboard-configuration/xkb-keymap=us <wait>",
      "netcfg/get_hostname=debian-12 <wait>",
      "netcfg/get_domain=localdomain <wait>",
      "fb=false <wait>",
      "debconf/frontend=noninteractive <wait>",
      "console-setup/ask_detect=false <wait>",
      "console-keymaps-at/keymap=us <wait>",
      "<enter><wait>"
    ]
  }
  
  debian_13 = {
    guest_os_type    = "debian12_64Guest"
    iso_url          = "https://cdimage.debian.org/debian-cd/daily-builds/daily/arch-latest/amd64/iso-cd/debian-testing-amd64-netinst.iso"
    iso_checksum     = "file:https://cdimage.debian.org/debian-cd/daily-builds/daily/arch-latest/amd64/iso-cd/SHA256SUMS"
    vm_name          = "debian-13-template-${local.vm_name_timestamp}"
    boot_command = [
      "<esc><wait>",
      "install <wait>",
      "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-13/preseed.cfg <wait>",
      "debian-installer=en_US.UTF-8 <wait>",
      "auto <wait>",
      "locale=en_US.UTF-8 <wait>",
      "kbd-chooser/method=us <wait>",
      "keyboard-configuration/xkb-keymap=us <wait>",
      "netcfg/get_hostname=debian-13 <wait>",
      "netcfg/get_domain=localdomain <wait>",
      "fb=false <wait>",
      "debconf/frontend=noninteractive <wait>",
      "console-setup/ask_detect=false <wait>",
      "console-keymaps-at/keymap=us <wait>",
      "<enter><wait>"
    ]
  }
  
  ubuntu_22_04 = {
    guest_os_type    = "ubuntu64Guest"
    iso_url          = "https://releases.ubuntu.com/22.04/ubuntu-22.04.4-live-server-amd64.iso"
    iso_checksum     = "sha256:45f873de9f8cb637345d6e66a583762730bbea30277ef7b32c9c3bd6700a32b2"
    vm_name          = "ubuntu-22.04-template-${local.vm_name_timestamp}"
    boot_command = [
      "<esc><wait>",
      "linux /casper/vmlinuz <wait>",
      "initrd /casper/initrd <wait>",
      "autoinstall <wait>",
      "ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-22.04/ <wait>",
      "<enter><wait>"
    ]
  }
  
  ubuntu_24_04 = {
    guest_os_type    = "ubuntu64Guest"
    iso_url          = "https://releases.ubuntu.com/24.04/ubuntu-24.04.1-live-server-amd64.iso"
    iso_checksum     = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
    vm_name          = "ubuntu-24.04-template-${local.vm_name_timestamp}"
    boot_command = [
      "<esc><wait>",
      "linux /casper/vmlinuz <wait>",
      "initrd /casper/initrd <wait>",
      "autoinstall <wait>",
      "ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ubuntu-24.04/ <wait>",
      "<enter><wait>"
    ]
  }
}