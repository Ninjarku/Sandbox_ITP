terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.pm_host}:8006/api2/json"
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = var.pm_tls_insecure
}
