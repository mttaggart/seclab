packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

variable "hostname" {
  type    = string
  default = "seclab-win-server-22"
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
    iso_file                 = "local:iso/Win-Server-2022.iso"
    iso_checksum             = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
    unmount      = true
  }
  insecure_skip_tls_verify = true
  communicator             = "ssh"
  ssh_username             = "${local.username}"
  ssh_password             = "${local.password}"
  ssh_timeout              = "30m"
  qemu_agent               = true
  cores                    = 4
  memory                   = 8192
  vm_name                  = "seclab-win-server-22"
  template_description     = "Base Seclab Windows Server 2022"
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
    iso_file     = "local:iso/Autounattend-win-server-2022.iso"
    iso_checksum = "sha256:c2c6bb24e262673fa903d8b1c277a5e6d6344779a324e65aae7206be4ab40297"
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
