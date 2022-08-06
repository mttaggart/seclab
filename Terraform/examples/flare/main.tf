terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.10"
    }
  }
}

variable proxmox_host {
  type        = string
  default     = "starbase"
  description = "description"
}

variable "username" {
  type        = string
  default     = "seclab"
  description = "username"
}

variable "password" {
  type        = string
  default     = "Seclab123!"
  description = "password"
}


provider "proxmox" {
  # Configuration options
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure     = true
  pm_log_enable       = true
}

resource "proxmox_vm_qemu" "flare" {
  cores       = 8
  memory      = 8192
  name        = "Flare-VM"
  target_node = "starbase"
  clone       = "seclab-win-ws"
  full_clone  = false
  agent       = 1

  disk {
    type         = "virtio"
    size         = "120G"
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

  provisioner "remote-exec" {
    inline = [
      "ipconfig"
    ]
  }

}

output "flare-id" {
  value       = proxmox_vm_qemu.flare.id
  sensitive   = false
  description = "VM ID"
}

output "flare-ip" {
  value       = proxmox_vm_qemu.flare.default_ipv4_address
  sensitive   = false
  description = "VM IP"
}