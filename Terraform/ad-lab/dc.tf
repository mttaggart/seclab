variable "dc_hostname" {
  type        = string
  default     = "ZD-DC-01"
  description = "description"
}

resource "proxmox_vm_qemu" "zd-dc" {
  cores       = 2
  memory      = 4096
  name        = "${var.dc_hostname}"
  target_node = "${var.proxmox_host}"
  clone       = "seclab-win-dc"
  full_clone  = false
  agent       = 1

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
      "powershell.exe -c Rename-Computer ${var.dc_hostname}"
    ]
  }

}

output "zd-dc-ip" {
  value       = proxmox_vm_qemu.zd-dc.default_ipv4_address
  sensitive   = false
  description = "Domain Controller IP (Change me!)"
}