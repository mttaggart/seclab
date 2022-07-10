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
      "echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIb5yqCWIgscV/Rv/gA8bieryhaTKsdrvAY1Jw7LbP1wB8RD0lOjj52Xt+FScGvKiFw4HHk2KUjZ8RwGFFtA7KIZ08ZeiJKXCTsO4DFjznrFf8Gmb1A2g3m8lv3hT35S+zehcI2gQHSbBrrywjSgogN5iTTqZepDb7CBvy35cmy1573Le3ib59jhoH0fUvclnThR/nvZv/kzlsIQ+XNFDLVYBfWMswsxa10RmygjbU6XP2i/CzxIbnPptF1S98h4vSbCjLZ+6rV29+Ir1VAg9r5nJ4fFSlFs5g8+QdQxx/2WJDGpCUaix/gAV9235cTEeqPKah/t7pI+X+XhNqMy9OvgUi+heCu8e3skoPZl5a3JYS+DjGHz4q5pjAtd3itZ7mqq0JMD07Pa1/gi6Fy9F291PooZReY9nAhQLKHQIaV8PD98Ss+kLOOegcidLxzMc/HeiCFXB0TbYUtUs0PohB5WBdGSQK7bRhBZYyRQC/lF+QamzNM2aCvK1o/7aRYGU= mttaggart@seclab-jumpbox' > /home/seclab/.ssh/authorized_keys",
      "chmod 0600 /home/seclab/.ssh/authorized_keys"
    ]
  }
}
