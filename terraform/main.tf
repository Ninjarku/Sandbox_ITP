# Before you run the terraform, install terraform, and run the following commands in order
# terraform init
# terraform plan 
# terraform apply -auto-approve


# important: change, users and the template name as how you have created it
/* create a terraform.tfvars with these 
pm_user = "<proxmox user>"
pm_password = "<proxmox user password>"
pm_host = "<proxmox ip>"
*/

resource "proxmox_vm_qemu" "cape2" {
  name              = "cape2"
  target_node       = var.pm_node_name
  clone             = var.template_vm_name
  full_clone        = true
  cores             = 2
  memory            = var.vm_memory
  onboot = true
  

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  disk {
    size    = var.vm_disk_size 
    storage = var.vm_disk_location
    type    = "disk"
    slot    = "scsi0"
  }
  scsihw    = "virtio-scsi-single"

  disk {
    type    = "cloudinit"
    size    = var.vm_disk_size 
    storage = var.vm_disk_location
    slot    = "ide2"
  }

  ciuser       = "cape"                           # Set the username
  cipassword   = "cape_pass"                      # Optional: Set a password (use cautiously)
  sshkeys  = file("~/.ssh/id_rsa.pub")
  ipconfig0  = "ip=${var.cape_host}/24,gw=${var.pm_host}" # Set static IP and gateway
  
  connection {
    type        = "ssh"
    host        = var.cape_host
    user        = "cape"
    private_key = file("~/.ssh/id_rsa")
  }
}

# Wait for SSH to become available
resource "null_resource" "wait_for_ssh" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Waiting for SSH to become available...";
      while ! nc -z ${var.cape_host} 22; do
        echo "SSH not ready, retrying in 5 seconds...";
        sleep 5;
      done;
      echo "SSH is now available.";
    EOT
  }

  triggers = {
    always_run = timestamp() # Ensures this always runs
  }

  depends_on = [proxmox_vm_qemu.cape2]
}

# Run Ansible playbook after SSH is ready
resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = <<EOT
      echo "Ensuring SSH is fully available before running Ansible...";
      while ! ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa cape@${var.cape_host} "exit" 2>/dev/null; do
        echo "SSH not ready, retrying in 5 seconds...";
        sleep 5;
      done;
      echo "SSH is fully available. Running Ansible playbook...";
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ../automate_infra/inventory.ini \
        --private-key ~/.ssh/id_rsa \
        --become \
        ../automate_infra/playbook_cape_v2.yaml;
    EOT
  }

  triggers = {
    always_run = timestamp() # Ensures this provisioner always runs
  }

  depends_on = [null_resource.wait_for_ssh]
}
