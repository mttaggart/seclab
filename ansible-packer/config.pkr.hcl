packer {
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "username" {
  type    = string
  default = "seclab"
}

variable "password" {
  type    = string
  default = "seclab"
}

source "virtualbox-iso" "ansible-server" {
  skip_export            = false
  format                 = "ova"
  guest_os_type          = "Ubuntu_64"
  iso_url                = "https://releases.ubuntu.com/focal/ubuntu-20.04.3-live-server-amd64.iso"
  iso_checksum           = "sha256:f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
  ssh_username           = "${var.username}"
  ssh_password           = "${var.password}"
  ssh_handshake_attempts = 30
  ssh_timeout            = "4h"
  http_directory         = "http"
  shutdown_command       = "echo ${var.password} | sudo -S shutdown -P now"
  cpus                   = 2
  memory                 = 2048
  vm_name                = "ansible-server"
  boot_wait              = "5s"
  boot_command = [
    " <wait><enter><wait>",
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
  
  vboxmanage = [
   ["modifyvm", "{{.Name}}", "--memory", "1024"],
   ["modifyvm", "{{.Name}}", "--cpus", "2"],
   ["modifyvm", "{{.Name}}", "--nic2", "intnet", "--intnet2", "isolation"],
  ]

}

build {
  sources = ["sources.virtualbox-iso.ansible-server"]
  provisioner "file" {
    source = "00-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }
  provisioner "shell" {
    inline = [
      "echo ${var.password} | sudo -S apt update && sudo apt install -y ansible",
      "echo ${var.password} | sudo -S ansible-galaxy collection install ansible.windows",
      "echo ${var.password} | sudo -S mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak",
      "echo ${var.password} | sudo -S mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
    ]
  }
}
