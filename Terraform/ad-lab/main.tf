terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.48.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.16.0"
    }
  }
}

variable "proxmox_host" {
  type        = string
  default     = "proxmox"
  description = "Proxmox node name"
}

variable "dc_template_id" {
  type        = string
  description = "Template ID for DC clone"
}

variable "fs_template_id" {
  type        = string
  description = "Template ID for Server clone"
}

variable "ws_template_id" {
  type        = string
  description = "Template ID for Workstation clones"
}

provider "vault" {

}

data "vault_kv_secret_v2" "seclab" {
  mount = "seclab"
  name  = "seclab"
}

provider "proxmox" {
  # Configuration options
  endpoint  = "https://${var.proxmox_host}:8006/api2/json"
  insecure  = true
  api_token = "${data.vault_kv_secret_v2.seclab.data.proxmox_api_id}=${data.vault_kv_secret_v2.seclab.data.proxmox_api_token}"
}

resource "proxmox_virtual_environment_pool" "zeroday_pool" {
  comment = "ZeroDay Pool"
  pool_id = "ZeroDay"
}
