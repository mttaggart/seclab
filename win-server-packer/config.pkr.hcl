variable "hostname" {
  type    = string
  default = "seclab-win-ws"
}

variable "username" {
  type    = string
  default = "Administrator"
}

variable "password" {
  type    = string
  default = "Seclab123!"
}

source "proxmox-iso" "seclab-win-server" {
  proxmox_url  = "https://192.168.1.50:8006/api2/json"
  username     = "mttaggart@pam!mttaggart"
  token        = "9525cd7a-66cc-4df9-9bd3-f87e9b0ca2d3"
  node         = "starbase"
  iso_file     = "local:iso/17763.737.190906-2324.rs5_release_svc_refresh_SERVER_EVAL_x64FRE_en-us_1.iso"
  iso_checksum = "sha256:549bca46c055157291be6c22a3aaaed8330e78ef4382c99ee82c896426a1cee1"


  additional_iso_files {
    device       = "ide3"
    iso_file     = "local:iso/Autounattend-WinServer.iso"
    iso_checksum = "sha256:b61fb312be4d025fb148d7b31b792f94b217399adc31974973d26e73e1a7541f"
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
  ssh_timeout  = "15m"
  qemu_agent   = false
  ssh_host     = "10.1.99.253"
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
    inline = ["ipconfig"]
  }
  # provisioner "shell-local" {
  #   pause_before = "15m"
  #   inline = ["echo Done! Now go make a template from it"]
  # }
}
