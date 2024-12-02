# Sandbox_ITP
ITP Sandbox project
Current Configurations done:
- WMI Spoofing
- Registry Key strings replacement
- NtYieldExection spoofing

Testware password: infected


# Automation
To use the Automated Proxmox Sandbox creation, you need to do the following:

## Create a proxmox template
Follow this guide, it is quite closely related to what we want to achieve
```
https://medium.com/@AdminGuideEN/proxmox-preparing-vm-template-from-cloudinit-image-of-ubuntu-server-22-d06028332e10
```

But the additional step is the adding in of our own Ubuntu Public key in the Cloudinit for private key ssh access later on with ansible

## Create a terraform account so that you can alter things in the proxmox with a terraform user account rather than root.
Run in your Proxmox shell to setup the terraform user account
```
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"

pveum user add terraform-prov@pve --password <password>

pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

An example would be the following:
```
pveum role add TerraformProv -privs "Datastore.AllocateSpace Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.Monitor VM.PowerMgmt SDN.Use"

pveum user add terraform-prov@pve --password terraform

pveum aclmod / -user terraform-prov@pve -role TerraformProv
```

## Create inventory.ini

In `Sandbox_ITP\automate_infra`, you will need to create a file called inventory.ini with the following example contents:
```
[cape]
<CAPE_IP> ansible_user=<CAPE USER> ansible_become=true ansible_ssh_private_key_file=<YOUR PRIVATE KEY LOCATION>
```

Be sure to update the fields accordingly, an example would be such:
```
[cape]
192.168.65.158 ansible_user=cape ansible_become=true ansible_ssh_private_key_file=~/.ssh/id_rsa
```
## Create terraform.tfvars
In `Sandbox_ITP\terraform` you will need to create a terraform.tfvars file and add in the contents as such:
```
pm_user = <TERRAFORM USER ACCOUNT CREATED PRIOR>
pm_password = <TERRAFORM USER PASSWORD>
pm_host = <PROXMOX ip>
template_vm_name = <NAME OF TEMPLATE YOU CREATED>
cape_host = <IP OF CAPE MACHINE>
vm_disk_size = <SIZE OF CAPE VM DISK FOR NESTED VM>
vm_memory = <MEMORY FOR CAPE>
```
An example config will look like this
```
pm_user = "terraform-prov@pve"
pm_password = "terraform"
pm_host = "192.168.65.156"
template_vm_name = "CAPE2"
cape_host = "192.168.65.158"
vm_disk_size = "200G"
vm_memory = 12288
```
There are more vairables that can be configured with this, but these are the main ones to change for this to work.

## Create a new .qcow disk image file
Create a .qcow file with the documentation in this git: `Create NewDiskImage.pdf`, then 7zip it and put it in the `Sandbox_ITP\automate_infra` directory with the zip name  `win10-main-analysis-vm.7z`

## Run init.sh
Once you have completed the above steps, you are ready to initialise terraform to create the machines.
Navigate to `Sandbox_ITP\terraform` directory and run:
```
chmod +x init.sh
./init.sh
```

Once it is done you should have your cape machine setup with a nested KVM Windows 10 machine.
