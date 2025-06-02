packer {
  required_plugins {
    proxmox = {
      version = "= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
    keepass = {
      version = ">= 0.3.0"
      source  = "github.com/chunqi/keepass"
    }
  }
}

variable "keepass_database" {
  type    = string
  default = "../../seclab.kdbx"
}

variable "keepass_password" {
  type      = string
  sensitive = true
}

variable "ca_cert_path" {
  type    = string
  default = "../../pki/ca.crt"
}

data "keepass-credentials" "kpxc" {
  keepass_file     = "${var.keepass_database}"
  keepass_password = "${var.keepass_password}"
}

variable "hostname" {
  type    = string
  default = "win-server-25"
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}

variable "proxmox_api_host" {
  type    = string
  default = "proxmox"
}

variable "storage_pool" {
  type    = string
  default = "local-lvm"
}

variable "iso_storage" {
  type    = string
  default = "local"
}

locals {
  username          = data.keepass-credentials.kpxc.map["/Passwords/Seclab/seclab_windows-UserName"]
  password          = data.keepass-credentials.kpxc.map["/Passwords/Seclab/seclab_windows-Password"]
  proxmox_api_id    = data.keepass-credentials.kpxc.map["/Passwords/Seclab/proxmox_api-UserName"]
  proxmox_api_token = data.keepass-credentials.kpxc.map["/Passwords/Seclab/proxmox_api-Password"]
}


source "proxmox-iso" "seclab-win-server" {
  proxmox_url = "https://${var.proxmox_api_host}:8006/api2/json"
  node        = "${var.proxmox_node}"
  username    = "${local.proxmox_api_id}"
  token       = "${local.proxmox_api_token}"
  boot_iso {
    type         = "sata"
    iso_file     = "${var.iso_storage}:iso/Win-Server-2025.iso"
    iso_checksum = "sha256:d0ef4502e350e3c6c53c15b1b3020d38a5ded011bf04998e950720ac8579b23d"
    unmount      = true
  }
  insecure_skip_tls_verify = true
  communicator             = "ssh"
  ssh_username             = "${local.username}"
  ssh_password             = "${local.password}"
  ssh_timeout              = "30m"
  qemu_agent               = true
  machine                  = "pc-q35-9.0"
  cpu_type                 = "x86-64-v2-AES"
  cores                    = 4
  os                       = "win11"
  memory                   = 8192
  vm_name                  = "seclab-win-server-25"
  template_description     = "Base Seclab Windows Server 2025"
  bios                     = "ovmf"
  boot                     = "order=sata0;virtio0"
  boot_wait                = "5s"
  boot_command             = [
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<wait60s><enter>"
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
    index        = 1
    type         = "sata"
    iso_file     = "${var.iso_storage}:iso/Autounattend-win-server-2025.iso"
    iso_checksum = "sha256:da461a34c9fac48763b22b1bf7dfc7f1a607868c3f5d6b2249c0d81396938d71"
  }
  
  additional_iso_files {
    index        = 2
    type         = "sata"
    iso_file     = "${var.iso_storage}:iso/virtio.iso"
    iso_checksum = "sha256:57b0f6dc8dc92dc2ae8621f8b1bfbd8a873de9bedc788c4c4b305ea28acc77cd"
  }

  network_adapters {
    bridge = "vmbr2"
  }

  disks {
    type         = "virtio"
    disk_size    = "60G"
    storage_pool = "${var.storage_pool}"
    format       = "raw"
  }
  scsi_controller = "virtio-scsi-single"
}


build {
  sources = ["sources.proxmox-iso.seclab-win-server"]
  provisioner "file" {
    source      = "${var.ca_cert_path}"
    destination = "C:/Windows/Temp/ca.crt"
  }
  provisioner "windows-shell" {
    inline = [
      "powershell.exe -c Import-Certificate -FilePath C:\\Windows\\Temp\\ca.crt -CertStore Cert:\\LocalMachine\\Root",
      "powershell.exe -c Rename-Computer ${var.hostname}",
      "ipconfig"
    ]
  }
}
