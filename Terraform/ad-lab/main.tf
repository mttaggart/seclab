terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.76.0"
    }
    keepass = {
      source  = "iSchluff/keepass"
      version = "1.0.1"
    }
  }
}

variable "keepass_password" {
  type      = string
  sensitive = true
  ephemeral = true
}

variable "keepass_database" {
  type    = string
  default = "../../seclab.kdbx"
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

variable "server_template_id" {
  type        = string
  description = "Template ID for Server clones"
}

variable "workstation_template_id" {
  type        = string
  description = "Template ID for Workstation clones"
}

variable "domain" {
  type        = string
  description = "AD Lab Domain"
  default     = "zeroday.local"
}

variable "pool_name" {
  type        = string
  description = "Resource pool label"
  default     = "ZeroDay"
}

variable "num_servers" {
  type        = number
  description = "Number of servers to generate"
  default     = 2
}

variable "num_workstations" {
  type        = number
  description = "Number of workstations to generate"
  default     = 2
}

provider "keepass" {
  database = var.keepass_database
  password = var.keepass_password
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
  comment = "AD Lab Pool"
  pool_id = "${var.pool_name}"
}
