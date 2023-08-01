packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "hostname" {
  type    = string
  default = "seclab-kali"
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}

locals {
  username          = vault("/seclab/data/seclab/", "seclab_user")
  password          = vault("/seclab/data/seclab/", "seclab_password")
  proxmox_api_id      = vault("/seclab/data/seclab/", "proxmox_api_id")
  proxmox_api_token = vault("/seclab/data/seclab/", "proxmox_api_token")
}


source "proxmox-iso" "seclab-kali" {
  proxmox_url              = "https://${var.proxmox_node}:8006/api2/json"
  node                     = "${var.proxmox_node}"
  username                 = "${local.proxmox_api_id}"
  token                    = "${local.proxmox_api_token}"
  iso_file                 = "local:iso/kali.iso"
  iso_checksum             = "sha256:4aeaac60c69fb7137beaaef1fa48c194431274bcb8abf2d9f01c1087c8263b6a"
  ssh_username             = "${local.username}"
  ssh_password             = "${local.password}"
  ssh_handshake_attempts   = 100
  ssh_timeout              = "4h"
  http_directory           = "http"
  cores                    = 4
  memory                   = 8192
  vm_name                  = "seclab-kali"
  qemu_agent               = true
  template_description     = "Kali"
  insecure_skip_tls_verify = true


  network_adapters {
    bridge = "vmbr2"
  }

  disks {
    disk_size    = "50G"
    storage_pool = "local-lvm"
  }
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "/install.amd/vmlinuz noapic ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kali.preseed ",
    "hostname=seclab-kali ",
    "auto=true ",
    "interface=auto ",
    "domain=vm ",
    "initrd=/install.amd/initrd.gz -- <enter>"
  ]
}

build {
  sources = ["sources.proxmox-iso.seclab-kali"]
}
