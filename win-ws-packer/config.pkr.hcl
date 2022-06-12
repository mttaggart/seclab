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

source "proxmox-iso" "seclab-win-ws" {
  proxmox_url  = "https://192.168.1.50:8006/api2/json"
  username     = "mttaggart@pam!mttaggart"
  token        = "9525cd7a-66cc-4df9-9bd3-f87e9b0ca2d3"
  node         = "starbase"
  iso_file                 = "local:iso/win10-enterprise.iso"
  iso_checksum            = "sha256:69efac1df9ec8066341d8c9b62297ddece0e6b805533fdb6dd66bc8034fba27a"
  /*skip_export             = true*/
  communicator            = "ssh"
  ssh_username = "${var.username}"
  ssh_password = "${var.password}"
  ssh_timeout  = "15m"
  qemu_agent   = false
  ssh_host     = "10.1.99.253"
  cores                   = 2
  memory                  = 4096
  vm_name                 = "seclab-win-ws"
  template_description = "Base Seclab Windows Server"
  
  additional_iso_files {
    device       = "ide3"
    iso_file     = "local:iso/Autounattend-WinDesktop.iso"
    iso_checksum = "sha256:7de1fc364e44c54f5b28aa1ebdef5cfe72c1927c33100500a7ee7e243d835bfa"
    unmount      = true
  }

  additional_iso_files {
    device       = "sata0"
    iso_file     = "local:iso/virtio.iso"
    iso_checksum = "sha256:af2b3cc9fa7905dea5e58d31508d75bba717c2b0d5553962658a47aebc9cc386"
    unmount      = true
  }

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
  sources = ["sources.proxmox-iso.seclab-win-ws"]
  provisioner "windows-shell" {
    inline = ["ipconfig"]
  }
}
