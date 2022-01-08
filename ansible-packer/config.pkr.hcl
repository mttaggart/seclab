
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
    default = "seclab-ansible"
}

source "hyperv-iso" "seclab-ansible" {
  skip_export            = false
  iso_url                = "https://releases.ubuntu.com/focal/ubuntu-20.04.3-live-server-amd64.iso"
  iso_checksum           = "sha256:f8e3086f3cea0fb3fefb29937ab5ed9d19e767079633960ccb50e76153effc98"
  ssh_username           = "${var.username}"
  ssh_password           = "${var.password}"
  ssh_handshake_attempts = 100
  ssh_timeout            = "4h"
  http_directory         = "http"
  switch_name            = "Default Switch"
  shutdown_command       = "echo ${var.password} | sudo -S shutdown -P now"
  cpus                   = 2
  memory                 = 2048
  vm_name                = "seclab-ansible"
  boot_wait              = "10s"
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

}

build {
  sources = ["sources.hyperv-iso.seclab-ansible"]
  provisioner "file" {
    source = "00-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }
  provisioner "shell" {
    inline = [
      "git clone https://github.com/mttaggart/seclab-playbooks",
      "sudo apt update && sudo apt install -y ansible",
      "sudo ansible-galaxy collection install ansible.windows",
      "sudo ansible-galaxy collection install community.mysql",
      "sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak",
      "sudo mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
    ]
  }
}
