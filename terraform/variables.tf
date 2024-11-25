variable "pm_user" {
  description = "The username for the proxmox user"
  type        = string
  sensitive   = false
  #default     = "terraform-prov@pve"  # Replace with your Proxmox user
}

variable "pm_password" {
  description = "The password for the proxmox user"
  type        = string
  sensitive   = true
  #default     = "terraform"  # Replace with your Proxmox password
}

variable "pm_tls_insecure" {
  description = "Set to true to ignore certificate errors"
  type        = bool
  default     = true
}

variable "pm_host" {
  description = "The hostname or IP of the proxmox server"
  type        = string
  #default     = "192.168.75.132"  # Replace with your Proxmox server IP/hostname
}

variable "pm_node_name" {
  description = "Name of the proxmox node to create the VMs on"
  type        = string
  default     = "pve"  # Replace with your Proxmox node name
}

variable "pvt_key" {
  description = "Private key file"
  type        = string
  default     = "~/.ssh/id_rsa"  # Optional: Path to your private key if needed
}

variable "template_vm_name" {
  description = "The name of the Proxmox template VM to be cloned"
  type        = string
  default     = "cape"  # Replace with your template name
}

variable "vm_memory" {
  description = "The amount of RAM for the VM"
  type        = number
  default     = 4096  # Replace with desired RAM in MB
}

variable "vm_disk_size" {
  description = "The size of the VM disk (e.g., 40G)"
  type        = string
  default     = "100G"  # Replace with your desired disk size
}

variable "vm_disk_type" {
  description = "The disk type (e.g., scsi)"
  type        = string
  default     = "scsi"
}

variable "vm_disk_location" {
  description = "The storage location for the VM disk (e.g., local-lvm)"
  type        = string
  default     = "local-lvm"  # Replace with your desired storage location
}


variable "cape_host" {
  description = "The host of ip of cape"
  type        = string
  default     = "192.168.65.158"  # Replace with your actual cape ip
}
