variable "fs_hostname" {
  type        = string
  default     = "ZD-FS-01"
  description = "username"
}

resource "proxmox_vm_qemu" "zd-fs" {
  cores       = 2
  memory      = 4096
  name        = "ZD-FS-01"
  target_node = "starbase"
  clone       = "seclab-win-server"
  full_clone  = false
  agent       = 1
  depends_on = [
    proxmox_vm_qemu.zd-dc
  ]

  disk {
    type         = "virtio"
    size         = "50G"
    storage      = "local-lvm"
  }

  network {
    bridge = "vmbr1"
    model = "e1000"
  }
  network {
    bridge = "vmbr2"
    model = "e1000"
  }

  connection {
    type = "ssh"
    user = "${var.username}"
    password = "${var.password}"
    host = self.default_ipv4_address
    target_platform = "windows"
  }

  # provisioner "file" {
  #   source = "./configure-fs.ps1"
  #   destination = "C:/Windows/Temp"
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "powershell.exe -ep Bypass -File C:\\Windows\\Temp\\configure-dc.ps1"
  #   ]
  # }

  # provisioner "remote-exec" {
  #   inline = [
  #     "powershell.exe -c Rename-Computer ${var.fs_hostname}",
  #     "ipconfig"
  #   ]
  # }


}