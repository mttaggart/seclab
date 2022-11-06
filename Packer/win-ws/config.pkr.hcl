variable "hostname" {
  type = string
  default = "seclab-win-ws"
}

variable "username" {
  type = string
  default = "seclab"
}

variable "password" {
  type = string
  default = "Seclab123!"
}

variable "proxmox_hostname" {
  type    = string
  default = "starbase"
}

source "proxmox-iso" "seclab-win-ws" {
  proxmox_url  = "https://${var.proxmox_hostname}:8006/api2/json"
  node         = "${var.proxmox_hostname}"
  iso_file                 = "local:iso/Win-10-Enterprise.iso"
  iso_checksum            = "sha256:ef7312733a9f5d7d51cfa04ac497671995674ca5e1058d5164d6028f0938d668"
  /*skip_export             = true*/
  communicator            = "ssh"
  ssh_username = "${var.username}"
  ssh_password = "${var.password}"
  ssh_timeout  = "30m"
  qemu_agent   = true
  cores                   = 2
  memory                  = 4096
  vm_name                 = "seclab-win-ws"
  template_description = "Base Seclab Windows Server"
  insecure_skip_tls_verify = true
  
  additional_iso_files {
    device       = "ide3"
    iso_file     = "local:iso/Autounattend-WinDesktop.iso"
    iso_checksum = "sha256:5f6aa4a2c9742c321f042dec7e8ce0aade465400643625f442b9d01836eb6ed4"
    unmount      = true
  }

  additional_iso_files {
    device       = "sata0"
    iso_file     = "local:iso/virtio.iso"
    iso_checksum = "sha256:8a066741ef79d3fb66e536fb6f010ad91269364bd9b8c1ad7f2f5655caf8acd8"
    unmount      = true
  }

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
  sources = ["sources.proxmox-iso.seclab-win-ws"]
  provisioner "windows-shell" {
    inline = ["ipconfig"]
  }
}
