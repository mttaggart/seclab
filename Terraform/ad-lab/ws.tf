variable "ws_hostname" {
  type        = string
  default     = "ZD-WS-01"
  description = "username"
}

resource "proxmox_vm_qemu" "zd-ws" {
  cores       = 2
  memory      = 4096
  name        = "${var.ws_hostname}"
  target_node = "${var.proxmox_host}"
  clone       = "seclab-win-ws"
  full_clone  = false
  agent       = 1
  depends_on = [
    proxmox_vm_qemu.zd-dc,
    proxmox_vm_qemu.zd-fs
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
      "powershell.exe -c Rename-Computer ${var.ws_hostname}",
    ]
  }


}

output "zd-ws-ip" {
  value       = proxmox_vm_qemu.zd-ws.default_ipv4_address
  sensitive   = false
  description = "Workstation IP (Change me!)"
}