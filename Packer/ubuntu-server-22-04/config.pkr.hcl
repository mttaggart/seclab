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

variable "proxmox_node" {
    type    = string
    default = "starbase"
}

variable "ssh_key" {
    type    = string
    default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCtMowTWuloUphN7EfoQ37EJ9STy6YG6lGHVKgEUIiVjF7m97kewJXq8Hi8XV6zL0d+DfJoQxIr9xXWQLz9ZI0jS0I/+Fx6MuYoZW2w3hVRwANenAS7stDDN0t1xlhrIin/BcPAfdp62A3gLZsovQRXAb+V1b21IirnZ8CkEzQBmMZrjgIkzmuS+HrmzNNYFHEJVARwNwuuhSYA8KYS4xhsdZq33V500oO2LGyldwBYvcNlXKHMaOWQdC7y8ykXisQt3U1glAB/JsHLo5whdYaVPiW50ONfCOlYF9PRa2DR06ioc/vs6FYDUnk7ANmXrFV59tG+ask1/Spjk40HmAkAwelj1R1XSOh4RjQHg2Pg6qtAFrJPVbNBmDQrpBDTo56mDn17G57fa3IDcwN/zSVMANHe6BMVfIVGxj37R42q9IQrMu83SThVZx75ZBZVOxwInkIRJg9JnJsDAQEZI7+0auaGy6UkSmcGY6DWo7RC0deEXYa1MBs7n8cH5sSCK3M= mttaggart@seclab-jumpbox"
}


source "proxmox-iso" "seclab-ubuntu-server" {
  proxmox_url            = "https://${var.proxmox_node}:8006/api2/json"
  node                   = "${var.proxmox_node}"
  iso_file               = "local:iso/ubuntu-22.04-live-server-amd64.iso"
  iso_checksum           = "sha256:84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f"
  ssh_username           = "${var.username}"
  ssh_password           = "${var.password}"
  ssh_handshake_attempts = 100
  ssh_timeout            = "4h"
  http_directory         = "http"
  cores                  = 2
  memory                 = 2048
  vm_name                = "seclab-ubuntu-server-22-04"
  qemu_agent             = true
  template_description   = "Ubuntu 22.04 Server"

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
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hostname",
      "mkdir /home/seclab/.ssh",
      "echo '${var.ssh_key}' > /home/seclab/.ssh/authorized_keys",
      "chmod 0600 /home/seclab/.ssh/authorized_keys"
    ]
  }
}
