packer {
  required_plugins {
    vsphere = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

source "vsphere-iso" "debian-12" {
  vcenter_server      = local.common_vm_settings.vcenter_server
  username            = local.common_vm_settings.username
  password            = local.common_vm_settings.password
  insecure_connection = local.common_vm_settings.insecure_connection
  
  datacenter     = local.common_vm_settings.datacenter
  cluster        = local.common_vm_settings.cluster
  datastore      = local.common_vm_settings.datastore
  folder         = local.common_vm_settings.folder
  resource_pool  = local.common_vm_settings.resource_pool
  
  vm_name       = local.debian_12.vm_name
  guest_os_type = local.debian_12.guest_os_type
  
  CPUs            = local.common_vm_settings.CPUs
  RAM             = local.common_vm_settings.RAM
  RAM_reserve_all = local.common_vm_settings.RAM_reserve_all
  firmware        = local.common_vm_settings.firmware
  
  disk_controller_type = local.common_vm_settings.disk_controller_type
  
  storage {
    disk_size             = local.common_vm_settings.storage.disk_size
    disk_thin_provisioned = local.common_vm_settings.storage.disk_thin_provisioned
  }
  
  network_adapters {
    network      = local.common_vm_settings.network_adapters.network
    network_card = local.common_vm_settings.network_adapters.network_card
  }
  
  iso_url      = local.debian_12.iso_url
  iso_checksum = local.debian_12.iso_checksum
  
  http_directory = "configs"
  
  boot_wait    = local.common_vm_settings.boot_wait
  boot_command = local.debian_12.boot_command
  
  ssh_timeout  = local.common_vm_settings.ssh_timeout
  ssh_username = local.common_vm_settings.ssh_username
  ssh_password = "root"
  
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  shutdown_timeout = local.common_vm_settings.shutdown_timeout
  
  remove_cdrom        = local.common_vm_settings.remove_cdrom
  convert_to_template = local.common_vm_settings.convert_to_template
}

build {
  name = "debian-12"
  
  sources = ["source.vsphere-iso.debian-12"]
  
  provisioner "shell" {
    script = "scripts/debian/setup.sh"
  }
  
  dynamic "provisioner" {
    for_each = local.common_provisioners
    content {
      type   = provisioner.value.type
      script = provisioner.value.script
      environment_vars = try(provisioner.value.environment_vars, [])
    }
  }
}