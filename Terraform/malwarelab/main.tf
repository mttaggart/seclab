terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.13"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.16.0"
    }
  }
}

provider "vault" {

}

data "vault_kv_secret_v2" "seclab" {
  mount = "kv2"
  name  = "seclab"
}

variable "proxmox_host" {
  type        = string
  default     = "starbase"
  description = "username"
}

provider "proxmox" {
  # Configuration options
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure     = true
  pm_log_enable       = true
  pm_log_file         = "terraform-plugin-proxmox.log"
  pm_debug            = true
}

