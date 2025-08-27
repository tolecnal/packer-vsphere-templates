variable "vcenter_server" {
  type        = string
  description = "vCenter server hostname or IP address"
  default     = env("VCENTER_SERVER")
}

variable "vcenter_user" {
  type        = string
  description = "vCenter username"
  default     = env("VCENTER_USER")
}

variable "vcenter_password" {
  type        = string
  description = "vCenter password"
  sensitive   = true
  default     = env("VCENTER_PASSWORD")
}

variable "vcenter_datacenter" {
  type        = string
  description = "vCenter datacenter name"
  default     = env("VCENTER_DATACENTER")
}

variable "vcenter_cluster" {
  type        = string
  description = "vCenter cluster name"
  default     = env("VCENTER_CLUSTER")
}

variable "vcenter_datastore" {
  type        = string
  description = "vCenter datastore name"
  default     = env("VCENTER_DATASTORE")
}

variable "vcenter_network" {
  type        = string
  description = "vCenter network name"
  default     = env("VCENTER_NETWORK")
}

variable "vcenter_folder" {
  type        = string
  description = "vCenter VM folder"
  default     = env("VCENTER_FOLDER")
}

variable "vcenter_resource_pool" {
  type        = string
  description = "vCenter resource pool"
  default     = env("VCENTER_RESOURCE_POOL")
}

variable "ansible_public_key" {
  type        = string
  description = "Ansible user SSH public key"
  default     = env("ANSIBLE_PUBLIC_KEY")
}

variable "vm_cpu_count" {
  type        = number
  description = "Number of CPU cores"
  default     = 2
}

variable "vm_memory_mb" {
  type        = number
  description = "Memory in MB"
  default     = 4096
}

variable "vm_disk_size_gb" {
  type        = number
  description = "Disk size in GB"
  default     = 64
}

variable "vm_network_card" {
  type        = string
  description = "Network adapter type"
  default     = "vmxnet3"
}

variable "vm_disk_controller_type" {
  type        = string
  description = "Disk controller type"
  default     = "pvscsi"
}

variable "vm_disk_thin_provisioned" {
  type        = bool
  description = "Enable thin provisioning"
  default     = true
}

variable "vm_firmware" {
  type        = string
  description = "VM firmware type (bios or efi)"
  default     = "efi"
}

variable "boot_wait" {
  type        = string
  description = "Boot wait time"
  default     = "10s"
}

variable "ssh_timeout" {
  type        = string
  description = "SSH timeout"
  default     = "30m"
}

variable "shutdown_timeout" {
  type        = string
  description = "Shutdown timeout"
  default     = "15m"
}

variable "ansible_user" {
  type        = string
  description = "Ansible service account username"
  default     = "ansible"
}

variable "ansible_user_password" {
  type        = string
  description = "Ansible service account password"
  sensitive   = true
  default     = env("ANSIBLE_USER_PASSWORD")
}