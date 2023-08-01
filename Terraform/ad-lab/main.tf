terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
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
  mount = "seclab"
  name  = "seclab"
}

variable "proxmox_host" {
  type        = string
  default     = "proxmox"
  description = "proxmox node"
}

provider "proxmox" {
  # Configuration options
  pm_api_url      = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure = true
  pm_log_enable   = true
  pm_api_token_id = data.vault_kv_secret_v2.seclab.data.proxmox_api_id
  pm_api_token_secret = data.vault_kv_secret_v2.seclab.data.proxmox_api_token
}
