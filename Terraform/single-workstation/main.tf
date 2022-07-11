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



provider "proxmox" {
  # Configuration options
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure     = true
  pm_log_enable       = true
}

resource "proxmox_vm_qemu" "demo-ws" {
  cores       = 2
  memory      = 4096
  name        = "WS-TF-Demo"
  target_node = "starbase"
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