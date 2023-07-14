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
  default = "seclab-ubuntu-server"
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


source "proxmox-iso" "seclab-ubuntu-server" {
  proxmox_url              = "https://${var.proxmox_node}:8006/api2/json"
  node                     = "${var.proxmox_node}"
  username                 = "${local.proxmox_api_id}"
  token                    = "${local.proxmox_api_token}"
  iso_file                 = "local:iso/ubuntu-22.04-live-server-amd64.iso"
  iso_checksum             = "sha256:10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
  ssh_username             = "${local.username}"
  ssh_password             = "${local.password}"
  ssh_handshake_attempts   = 100
  ssh_timeout              = "4h"
  http_directory           = "http"
  cores                    = 2
  memory                   = 2048
  vm_name                  = "seclab-ubuntu-server-22-04"
  qemu_agent               = true
  template_description     = "Ubuntu 22.04 Server"
  insecure_skip_tls_verify = true

  network_adapters {
    bridge = "vmbr1"
  }
  disks {
    disk_size    = "30G"
    storage_pool = "local-lvm"
  }
  boot_wait = "10s"
  boot_command = [
    "<esc><esc><esc><esc>e<wait>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del>",
    "<del><del><del><del><del><del><del><del><del>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>",
    "<enter><f10><wait>"
  ]
}

build {
  sources = ["sources.proxmox-iso.seclab-ubuntu-server"]
}
