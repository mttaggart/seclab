variable "hostname" {
  type    = string
  default = "seclab-win-ws"
}

variable "username" {
  type    = string
  default = "seclab"
}

variable "password" {
  type    = string
  default = "Seclab123!"
}

variable "proxmox_hostname" {
  type    = string
  default = "starbase"
}

source "proxmox-iso" "seclab-win-server" {
  proxmox_url  = "https://${var.proxmox_hostname}:8006/api2/json"
  node         = "${var.proxmox_hostname}"
  iso_file     = "local:iso/Win-Server-2019.iso"
  iso_checksum = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"


  additional_iso_files {
    device       = "ide3"
    iso_file     = "local:iso/Autounattend-Win-Server.iso"
    iso_checksum = "sha256:fe22fada8f98e2355a4bfac558d2e1f0082bfff47ca29ea7bfa87553a44d8ac1"
    unmount      = true
  }

  additional_iso_files {
    device       = "sata0"
    iso_file     = "local:iso/virtio.iso"
    iso_checksum = "sha256:af2b3cc9fa7905dea5e58d31508d75bba717c2b0d5553962658a47aebc9cc386"
    unmount      = true
  }

  communicator = "ssh"
  ssh_username = "${var.username}"
  ssh_password = "${var.password}"
  ssh_timeout  = "30m"
  qemu_agent   = true
  // winrm_use_ssl           = true
  // guest_os_type           = "Windows2019_64"
  cores                = 2
  memory               = 4096
  vm_name              = "seclab-win-server"
  template_description = "Base Seclab Windows Server"
  network_adapters {
    bridge = "vmbr1"
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
  sources = ["sources.proxmox-iso.seclab-win-server"]
  provisioner "windows-shell" {
    inline = [
      "ipconfig"
    ]
  }

}
