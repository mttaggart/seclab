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
  type = string
  default = "../../seclab.kdbx"
}

variable "keepass_password" {
  type = string
  sensitive = true
}

variable "ca_cert_path" {
  type = string
  default = "../../pki/ca.crt"
}

data "keepass-credentials" "kpxc" {
  keepass_file = "${var.keepass_database}"
  keepass_password = "${var.keepass_password}"
}

variable "hostname" {
  type    = string
  default = "win-server-22"
}

variable "proxmox_api_host" {
  type    = string
  default = "proxmox"
}

variable "proxmox_node" {
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

variable "network_adapter" {
  type    = string
  default = "vmbr2"
}

locals {
  username          = data.keepass-credentials.kpxc.map["/Passwords/Seclab/seclab_windows-UserName"]
  password          = data.keepass-credentials.kpxc.map["/Passwords/Seclab/seclab_windows-Password"]
  proxmox_api_id    = data.keepass-credentials.kpxc.map["/Passwords/Seclab/proxmox_api-UserName"]
  proxmox_api_token = data.keepass-credentials.kpxc.map["/Passwords/Seclab/proxmox_api-Password"]
}

source "proxmox-iso" "seclab-win-server" {
  proxmox_url              = "https://${var.proxmox_api_host}:8006/api2/json"
  node                     = "${var.proxmox_node}"
  username                 = "${local.proxmox_api_id}"
  token                    = "${local.proxmox_api_token}"
  boot_iso {
    type         = "sata"
    iso_file                 = "${var.iso_storage}:iso/Win-Server-2022.iso"
    iso_checksum             = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
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
  cores                    = 4
  memory                   = 8192
  vm_name                  = "seclab-win-server-22"
  template_description     = "Base Seclab Windows Server 2022"
  os                       = "win11"
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
    iso_file     = "${var.iso_storage}:iso/Autounattend-win-server-2022.iso"
    iso_checksum = "sha256:c2c6bb24e262673fa903d8b1c277a5e6d6344779a324e65aae7206be4ab40297"
  }
  
  additional_iso_files {
    index        = 2
    type         = "sata"
    iso_file     = "${var.iso_storage}:iso/virtio.iso"
    iso_checksum = "sha256:57b0f6dc8dc92dc2ae8621f8b1bfbd8a873de9bedc788c4c4b305ea28acc77cd"
  }

  network_adapters {
    bridge = "${var.network_adapter}"
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
