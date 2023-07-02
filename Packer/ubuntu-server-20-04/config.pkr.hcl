packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.2"
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
  username = vault("/kv2/data/seclab/", "seclab_username")
  password = vault("/kv2/data/seclab/", "seclab_password")
  ssh_key =  vault("/kv2/data/seclab/", "seclab_ssh_key")
}

source "proxmox-iso" "seclab-ubuntu-server" {
  proxmox_url            = "https://${var.proxmox_node}:8006/api2/json"
  node                   = "${var.proxmox_node}"
  iso_file               = "local:iso/ubuntu-20.04-live-server-amd64.iso"
  iso_checksum           = "sha256:f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
  ssh_username           = "${local.username}"
  ssh_password           = "${local.password}"
  ssh_handshake_attempts = 100
  ssh_timeout            = "4h"
  http_directory         = "http"
  cores                  = 2
  memory                 = 2048
  vm_name                = "seclab-ubuntu-server-20-04"
  qemu_agent             = true
  template_description   = "Seclab Ubuntu Server 20.04.3"

  network_adapters {
    bridge = "vmbr1"
  }
  # network_adapters {
  #   bridge = "vmbr2"
  # } 
  disks {
    disk_size         = "30G"
    storage_pool_type = "lvm"
    storage_pool      =  "local-lvm"
  }
  boot_wait              = "20s"
  boot_command = [
    "<wait><enter><wait>",
    "<f6><esc>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
    "<bs><bs><bs>",
    "/casper/vmlinuz ",
    "initrd=/casper/initrd ",
    "autoinstall ",
    "ds=nocloud-net;s=http://{{.HTTPIP}}:{{.HTTPPort}}/",
    "<enter>"
  ]
}

build {
  sources = ["sources.proxmox-iso.seclab-ubuntu-server"]
  
  provisioner "shell" {
    inline = [
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hostname",
      "mkdir /home/seclab/.ssh",
      "echo '${local.ssh_key}' > /home/seclab/.ssh/authorized_keys",
      "chmod 0600 /home/seclab/.ssh/authorized_keys"
    ]
  }
}
