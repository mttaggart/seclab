variable "fs_hostname" {
  type        = string
  default     = "ZD-FS-01"
  description = "username"
}

resource "proxmox_vm_qemu" "zd-fs" {
  cores       = 2
  memory      = 4096
  name        = "${var.fs_hostname}"
  target_node = "${var.proxmox_host}"
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
    bridge = "vmbr2"
    model = "e1000"
  }

  connection {
    type = "ssh"
    user = data.vault_kv_secret_v2.seclab.data.seclab_user
    password = data.vault_kv_secret_v2.seclab.data.seclab_windows_password
    host = self.default_ipv4_address
    target_platform = "windows"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -c Rename-Computer ${var.fs_hostname}"
    ]
  }

}

output "zd-fs-ip" {
  value       = proxmox_vm_qemu.zd-fs.default_ipv4_address
  sensitive   = false
  description = "File Server IP"
}