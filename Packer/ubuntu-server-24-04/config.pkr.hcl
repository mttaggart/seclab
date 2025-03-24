packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
    keepass = {
      version = ">= 0.3.0"
      source  = "github.com/chunqi/keepass"
    }
  }
}

variable "keepass_database" {
  type = string
  default = "../../seclab.kdbx"
}

variable "ca_cert_path" {
  type = string
  default = "../../pki/ca.crt"
}

variable "keepass_password" {
  type = string
  sensitive = true
}

variable "hostname" {
  type    = string
  default = "seclab-ubuntu-server"
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

data "keepass-credentials" "kpxc" {
  keepass_file = "${var.keepass_database}"
  keepass_password = "${var.keepass_password}"
}

locals {
  username          = data.keepass-credentials.kpxc.map["/Passwords/Seclab/seclab_user-UserName"]
  password          = data.keepass-credentials.kpxc.map["/Passwords/Seclab/seclab_user-Password"]
  proxmox_api_id    = data.keepass-credentials.kpxc.map["/Passwords/Seclab/proxmox_api-UserName"]
  proxmox_api_token = data.keepass-credentials.kpxc.map["/Passwords/Seclab/proxmox_api-Password"]
}


source "proxmox-iso" "seclab-ubuntu-server" {
  proxmox_url = "https://${var.proxmox_node}:8006/api2/json"
  node        = "${var.proxmox_node}"
  username    = "${local.proxmox_api_id}"
  token       = "${local.proxmox_api_token}"
  boot_iso {
    type         = "scsi"
    iso_file     = "local:iso/ubuntu-24.04.1-live-server-amd64.iso"
    iso_checksum = "sha256:e240e4b801f7bb68c20d1356b60968ad0c33a41d00d828e74ceb3364a0317be9"
    unmount      = true
  }
  ssh_username             = "${local.username}"
  ssh_password             = "${local.password}"
  ssh_handshake_attempts   = 100
  ssh_timeout              = "4h"
  http_directory           = "http"
  cores                    = 2
  memory                   = 2048
  vm_name                  = "seclab-ubuntu-24-04"
  qemu_agent               = true
  template_description     = "Ubuntu 24.04 Server"
  insecure_skip_tls_verify = true
  machine                  = "pc-q35-9.0"
  cpu_type                 = "x86-64-v2-AES"

  network_adapters {
    bridge = "vmbr1"
  }
  disks {
    type         = "virtio"
    disk_size    = "30G"
    storage_pool = "${var.storage_pool}"
    format       = "raw"
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
  provisioner "file" {
    source = "./00-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }
  provisioner "file" {
    source = "${var.ca_cert_path}"
    destination = "/tmp/ca.crt"
  }
  provisioner "shell" {
    inline = [
      "sudo cp /tmp/00-netplan.yaml /etc/netplan/",
      "rm /tmp/00-netplan.yaml",
      "sudo cp /tmp/ca.crt /usr/local/share/ca-certificates",
      "sudo update-ca-certificates"
    ]
  }
}
