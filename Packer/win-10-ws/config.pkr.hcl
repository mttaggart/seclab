packer {
  required_plugins {
    proxmox = {
      version = ">= 1.2.1"
      source  = "github.com/hashicorp/proxmox"
    }
    keepass = {
      version = ">= 0.3.0"
      source  = "github.com/chunqi/keepass"
    }
  }
}

variable "keepass_database" {
  type = string
  default = "../../seclab.kdbx"
}

variable "ca_cert_path" {
  type = string
  default = "../../pki/ca.crt"
}

variable "keepass_password" {
  type = string
  sensitive = true
}

data "keepass-credentials" "kpxc" {
  keepass_file = "${var.keepass_database}"
  keepass_password = "${var.keepass_password}"
}

variable "hostname" {
  type    = string
  default = "win10-ws"
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
  defautl = "local"
}

locals {
  username          = data.keepass-credentials.kpxc.map["/Passwords/Seclab/seclab_windows-UserName"]
  password          = data.keepass-credentials.kpxc.map["/Passwords/Seclab/seclab_windows-Password"]
  proxmox_api_id    = data.keepass-credentials.kpxc.map["/Passwords/Seclab/proxmox_api-UserName"]
  proxmox_api_token = data.keepass-credentials.kpxc.map["/Passwords/Seclab/proxmox_api-Password"]
}

variable "proxmox_node" {
  type    = string
  default = "proxmox"
}

source "proxmox-iso" "seclab-win-ws" {
  proxmox_url  = "https://${var.proxmox_api_host}:8006/api2/json"
  node         = "${var.proxmox_node}"
  username     = "${local.proxmox_api_id}"
  token        = "${local.proxmox_api_token}"
  boot_iso {
    type         = "sata"
    iso_file     = "${var.iso_storage}:iso/Win-10-Enterprise.iso"
    iso_checksum = "sha256:ef7312733a9f5d7d51cfa04ac497671995674ca5e1058d5164d6028f0938d668"
    unmount      = true
  }
  /*skip_export             = true*/
  communicator             = "ssh"
  ssh_username             = "${local.username}"
  ssh_password             = "${local.password}"
  ssh_timeout              = "60m"
  qemu_agent               = true
  cores                    = 2
  memory                   = 4096
  vm_name                  = "seclab-win10-ws"
  template_description     = "Base Seclab Windows Workstation"
  os                       = "win10"
  insecure_skip_tls_verify = true
  machine                  = "pc-q35-9.0"
  cpu_type                 = "x86-64-v2-AES"
  boot                     = "order=sata0;virtio0"
  boot_wait                = "5s"
  boot_command             = [
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<space><space><space><space><space><space>",
    "<wait30s><enter>"
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
    iso_file     = "${var.iso_storage}:iso/Autounattend-win-10-ws.iso"
    iso_checksum = "sha256:2893ca8f6d1f420436b6c213fa618710e7689a67d4bf924263361f07cced3b34"
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
    disk_size    = "50G"
    storage_pool = "${var.storage_pool}"
    format       = "raw"
  }
  scsi_controller = "virtio-scsi-pci"

}

build {
  sources = ["sources.proxmox-iso.seclab-win-ws"]
  provisioner "file" {
    source = "${var.ca_cert_path}"
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
