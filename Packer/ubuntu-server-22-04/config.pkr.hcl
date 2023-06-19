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
    default = "starbase"
}

locals {
  username = vault("/kv2/data/seclab/", "seclab_username")
  password = vault("/kv2/data/seclab/", "seclab_password")
  ssh_key =  vault("/kv2/data/seclab/", "seclab_ssh_key")
}


source "proxmox-iso" "seclab-ubuntu-server" {
  proxmox_url            = "https://${var.proxmox_node}:8006/api2/json"
  node                   = "${var.proxmox_node}"
  iso_file               = "local:iso/ubuntu-22.04-live-server-amd64.iso"
  iso_checksum           = "sha256:10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
  ssh_username           = "${local.username}"
  ssh_password           = "${local.password}"
  ssh_handshake_attempts = 100
  ssh_timeout            = "4h"
  http_directory         = "http"
  cores                  = 2
  memory                 = 2048
  vm_name                = "seclab-ubuntu-server-22-04"
  qemu_agent             = true
  template_description   = "Ubuntu 22.04 Server"
  insecure_skip_tls_verify = true

  network_adapters {
    bridge = "vmbr1"
  } 
  disks {
    disk_size         = "30G"
    storage_pool_type = "lvm"
    storage_pool      =  "local-lvm"
  }
  boot_wait              = "10s"
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
    "<del><del><del><del><del><del><del><del>",
    "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>",
    "<enter><f10><wait>"
  ]
}

build {
  sources = ["sources.proxmox-iso.seclab-ubuntu-server"]
  
  provisioner "shell" {
    inline = [
      "sudo sed -i 's/seclab-ubuntu-server/${local.hostname}/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-server/${local.hostname}/g' /etc/hostname",
      "mkdir /home/seclab/.ssh",
      "echo '${local.ssh_key}' > /home/seclab/.ssh/authorized_keys",
      "chmod 0600 /home/seclab/.ssh/authorized_keys"
    ]
  }
}
