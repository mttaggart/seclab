packer {
  required_plugins {
    proxmox = {
      version = "= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "hostname" {
  type    = string
  default = "seclab-win-server-25"
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}


variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

locals {
  username          = vault("/seclab/data/seclab/", "seclab_user")
  password          = vault("/seclab/data/seclab/", "seclab_windows_password")
  proxmox_api_id    = vault("/seclab/data/seclab/", "proxmox_api_id")
  proxmox_api_token = vault("/seclab/data/seclab/", "proxmox_api_token")
}


source "proxmox-iso" "seclab-win-server" {
  proxmox_url              = "https://${var.proxmox_node}:8006/api2/json"
  node                     = "${var.proxmox_node}"
  username                 = "${local.proxmox_api_id}"
  token                    = "${local.proxmox_api_token}"
  boot_iso {
    type         = "sata"
    iso_file                 = "local:iso/Win-Server-2025.iso"
    iso_checksum             = "sha256:d0ef4502e350e3c6c53c15b1b3020d38a5ded011bf04998e950720ac8579b23d"
    unmount      = true
  }
  insecure_skip_tls_verify = true
  machine                  = "pc-q35-9.0"
  cpu_type                 = "x86-64-v2-AES"
  communicator             = "ssh"
  ssh_username             = "${local.username}"
  ssh_password             = "${local.password}"
  ssh_timeout              = "30m"
  qemu_agent               = true
  machine                  = "pc-q35-9.0"
  cores                    = 4
  cpu_type                 = "x86-64-v2-AES"
  # cpu_type                 = "host"
  os                       = "win11"
  memory                   = 8192
  vm_name                  = "seclab-win-server-25"
  template_description     = "Base Seclab Windows Server 2025"
  bios                     = "ovmf"
  boot                     = "order=sata1;sata0"
  boot_wait                = "5s"
  boot_command             = [
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space><enter><wait>"
  ]
  efi_config {
    efi_storage_pool  = "${var.storage_pool}"
    efi_type          = "4m"
    pre_enrolled_keys = true
  }
  tpm_config {
    tpm_storage_pool = "${var.storage_pool}"
    tpm_version      = "v2.0"
  }

  additional_iso_files {
    index        = 2
    type         = "sata"
    iso_file     = "local:iso/virtio.iso"
    iso_checksum = "sha256:57b0f6dc8dc92dc2ae8621f8b1bfbd8a873de9bedc788c4c4b305ea28acc77cd"
    unmount      = true
  }

  additional_iso_files {
    index        = 3
    type         = "sata"
    iso_file     = "local:iso/Autounattend-win-server-2025.iso"
    iso_checksum = "sha256:da461a34c9fac48763b22b1bf7dfc7f1a607868c3f5d6b2249c0d81396938d71"
    unmount      = true
  }



  network_adapters {
    bridge = "vmbr2"
  }

  disks {
    type         = "sata"
    disk_size    = "60G"
    storage_pool = "${var.storage_pool}"
    format       = "raw"
  }
  scsi_controller = "virtio-scsi-single"
}


build {
  sources = ["sources.proxmox-iso.seclab-win-server"]
  provisioner "windows-shell" {
    inline = [
      "ipconfig",
    ]
  }

}
