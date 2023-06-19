variable "dc_hostname" {
  type        = string
  default     = "ZD-DC-01"
  description = "description"
}

# variable "sidchg_key" {
#   type        = string
#   default     = "77JAY-XeVvv-2OiL4-LJ"
#   description = "SIDCHG Trial key"
# }

resource "proxmox_vm_qemu" "zd-dc" {
  cores       = 2
  memory      = 4096
  name        = "ZD-DC-01"
  target_node = "starbase"
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
    user = data.vault_kv_secret_v2.seclab.data.seclab_username
    password = data.vault_kv_secret_v2.seclab.data.seclab_windows_password
    host = self.default_ipv4_address
    target_platform = "windows"
  }

}