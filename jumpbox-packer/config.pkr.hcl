packer {
  required_plugins {
    virtualbox = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

source "virtualbox-iso" "seclab-jumpbox" {
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
  shutdown_command       = "sudo shutdown -P now"
  cpus                   = 2
  memory                 = 2048
  vm_name                = "seclab-jumpbox"
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
   ["modifyvm", "{{.Name}}", "--vram", "128"],
   ["modifyvm", "{{.Name}}", "--memory", "4096"],
   ["modifyvm", "{{.Name}}", "--cpus", "2"],
   ["modifyvm", "{{.Name}}", "--nic2", "intnet", "--intnet2", "labnet"],
   ["modifyvm", "{{.Name}}", "--nic3", "intnet", "--intnet3", "isolation"],
  ]

}

build {
  sources = ["sources.virtualbox-iso.seclab-jumpbox"]
  provisioner "file" {
    source = "00-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }
  provisioner "shell" {
    inline = [
      "sudo apt update && sudo apt install -y ubuntu-desktop",
      "sudo apt install -y remmina remmina-plugin-rdp",
      "sudo apt install -y terminator",
      "sudo DEBIAN_FRONTEND=noninteractive apt install -y lightdm",
      "sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak",
      "sudo mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
    ]
  }
}
