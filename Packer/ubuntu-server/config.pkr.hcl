variable "username" {
  type    = string
  default = "seclab"
}

variable "password" {
  type    = string
  default = "seclab"
}

variable "hostname" {
    type    = string
    default = "seclab-ubuntu-server"
}

variable "proxmox_url" {
    type    = string
    default = "https://192.168.1.50:8006/api2/json"
}

variable "proxmox_node" {
    type    = string
    default = "starbase"
}


source "proxmox-iso" "seclab-ubuntu-server" {
  proxmox_url            = "${var.proxmox_url}"
  node                   = "${var.proxmox_node}"
  iso_file               = "local:iso/ubuntu-20.04.2-live-server-amd64.iso"
  iso_checksum           = "sha256:f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
  ssh_username           = "${var.username}"
  ssh_password           = "${var.password}"
  ssh_handshake_attempts = 100
  ssh_timeout            = "4h"
  http_directory         = "http"
  cores                  = 2
  memory                 = 2048
  vm_name                = "seclab-ubuntu-server"
  network_adapters {
    bridge = "vmbr1"
  }
  network_adapters {
    bridge = "vmbr2"
  } 
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
  provisioner "file" {
    source = "00-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }
  provisioner "shell" {
    inline = [
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hostname",
    ]
  }
}
