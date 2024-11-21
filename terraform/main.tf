# Before you run the terraform, install terraform, and run the following commands in order
# terraform init
# terraform plan 
# terraform apply

# important: change the apitoken, users and the template name as how you have created it
/* create a terraform.tfvars with these 
pm_user = "<proxmox user>"
pm_password = "<proxmox user password>"
pm_host = "<proxmox ip>"
*/
resource "proxmox_vm_qemu" "cape2" { # machine name that will be created.
  name            = "cape2"
  target_node     = var.pm_node_name
  clone           = var.template_vm_name
  cores           = 2
  memory          = var.vm_memory
  disk {
    size          = var.vm_disk_size
    storage       = var.vm_disk_location
    type          = var.vm_disk_type
  }
  network {
    model         = "virtio"
    bridge        = "vmbr0"
  }
}
