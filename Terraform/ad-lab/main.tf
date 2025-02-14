terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.71.0"
    }
    keepass = {
      source = "iSchluff/keepass"
      version = "1.0.1"
    }
  }
}

variable "keepass_password" {
  type       = string
  sensitive  = true
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

provider "keepass" {
  password = "${var.keepass_password}"
}

data "keepass_entry" "proxmox_api" {
  path = "Passwords/Seclab/proxmox_api"
}

data "keepass_entry" "seclab_user" {
  path = "Passwords/Seclab/seclab_user"
}

data "keepass_entry" "seclab_windows" {
  path = "Passwords/Seclab/seclab_windows"
}

data "keepass_entry" "seclab_windows_da" {
  path = "Passwords/Seclab/seclab_windows_da"
}

provider "proxmox" {
  # Configuration options
  endpoint  = "https://${var.proxmox_host}:8006/api2/json"
  insecure  = true
  api_token = "${data.keepass_entry.proxmox_api.username}=${data.keepass_entry.proxmox_api.password}"
}


resource "proxmox_virtual_environment_pool" "zeroday_pool" {
  comment = "ZeroDay Pool"
  pool_id = "ZeroDay"
}
