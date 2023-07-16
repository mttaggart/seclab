packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "hostname" {
  type = string
  default = "seclab-win-dc"
}

locals {
  username = vault("/seclab/data/seclab/", "seclab_username")
  password = vault("/seclab/data/seclab/", "seclab_windows_password")
}

variable "hostname" {
  type    = string
  default = "seclab-win-dc"
}

variable "proxmox_hostname" {
  type    = string
  default = "starbase"
}

source "proxmox-iso" "seclab-win-dc" {
  proxmox_url  = "https://${var.proxmox_hostname}:8006/api2/json"
  node         = "${var.proxmox_hostname}"
  iso_file     = "local:iso/Win-Server-2019.iso"
  iso_checksum = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"


  additional_iso_files {
    device       = "ide3"
    iso_file     = "local:iso/Autounattend-Win-Server.iso"
    iso_checksum = "sha256:b78cb8739d92fc319e838c4441b4c13009a44fcf5fc522af99314853f141bfe4"
    unmount      = true
  }

  additional_iso_files {
    device       = "sata0"
    iso_file     = "local:iso/virtio.iso"
    iso_checksum = "sha256:8a066741ef79d3fb66e536fb6f010ad91269364bd9b8c1ad7f2f5655caf8acd8"
    unmount      = true
  }

  insecure_skip_tls_verify  = true
  communicator = "ssh"
  ssh_username = "${local.username}"
  ssh_password = "${local.password}"
  ssh_timeout  = "30m"
  qemu_agent   = true
  // winrm_use_ssl           = true
  // guest_os_type           = "Windows2019_64"
  cores                = 2
  memory               = 4096
  vm_name              = "seclab-win-dc"
  template_description = "Base Seclab Windows Domain Controller"
  
  network_adapters {
    bridge = "vmbr2"
  }

  disks {
    type              = "virtio"
    disk_size         = "50G"
    storage_pool_type = "lvm"
    storage_pool      = "local-lvm"
  }
  scsi_controller = "virtio-scsi-pci"
}


build {
  sources = ["sources.proxmox-iso.seclab-win-dc"]
  provisioner "windows-shell" {
    inline = [
      "ipconfig",
      "c:\\windows\\system32\\sysprep\\sysprep.exe /generalize /mode:vm /oobe /quiet /quit /unattend:E:\\unattend.xml"
    ]
  }

}
