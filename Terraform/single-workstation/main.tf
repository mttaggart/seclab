terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.13"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.16.0"
    }
  }
}

variable "proxmox_host" {
  type        = string
  default     = "proxmox"
  description = "description"
}

variable "hostname" {
  type        = string
  default     = "seclab-ws"
  description = "description"
}

provider "vault" {

}

data "vault_kv_secret_v2" "seclab" {
  mount = "seclab"
  name  = "seclab"
}

provider "proxmox" {
  # Configuration options
  pm_api_url      = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure = true
  pm_log_enable   = true
  pm_api_token_id = data.vault_kv_secret_v2.seclab.data.proxmox_api_id
  pm_api_token_secret = data.vault_kv_secret_v2.seclab.data.proxmox_api_token
}


resource "proxmox_vm_qemu" "demo-ws" {
  cores       = 2
  memory      = 4096
  name        = "WS-TF-Demo"
  target_node = "proxmox"
  clone       = "seclab-win-ws"
  full_clone  = false
  agent       = 1

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
    user = data.vault_kv_secret_v2.seclab.data.seclab_user
    password = data.vault_kv_secret_v2.seclab.data.seclab_windows_password
    host = self.default_ipv4_address
    target_platform = "windows"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell.exe -c Rename-Computer '${var.hostname}'",
      "ipconfig"
    ]
  }


}

output "demo-id" {
  value       = proxmox_vm_qemu.demo-ws.id
  sensitive   = false
  description = "VM ID"
}

output "demo-ip" {
  value       = proxmox_vm_qemu.demo-ws.default_ipv4_address
  sensitive   = false
  description = "VM IP"
}