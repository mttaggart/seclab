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
  qemu_agent             = true

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
  
  provisioner "shell" {
    inline = [
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hostname",
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIb5yqCWIgscV/Rv/gA8bieryhaTKsdrvAY1Jw7LbP1wB8RD0lOjj52Xt+FScGvKiFw4HHk2KUjZ8RwGFFtA7KIZ08ZeiJKXCTsO4DFjznrFf8Gmb1A2g3m8lv3hT35S+zehcI2gQHSbBrrywjSgogN5iTTqZepDb7CBvy35cmy1573Le3ib59jhoH0fUvclnThR/nvZv/kzlsIQ+XNFDLVYBfWMswsxa10RmygjbU6XP2i/CzxIbnPptF1S98h4vSbCjLZ+6rV29+Ir1VAg9r5nJ4fFSlFs5g8+QdQxx/2WJDGpCUaix/gAV9235cTEeqPKah/t7pI+X+XhNqMy9OvgUi+heCu8e3skoPZl5a3JYS+DjGHz4q5pjAtd3itZ7mqq0JMD07Pa1/gi6Fy9F291PooZReY9nAhQLKHQIaV8PD98Ss+kLOOegcidLxzMc/HeiCFXB0TbYUtUs0PohB5WBdGSQK7bRhBZYyRQC/lF+QamzNM2aCvK1o/7aRYGU= mttaggart@seclab-jumpbox' > /home/seclab/.ssh/authorized_keys",
      "chmod 0600 /home/seclab/authorized_keys"
    ]
  }
}
