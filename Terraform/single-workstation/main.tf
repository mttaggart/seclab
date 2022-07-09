terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.10"
    }
  }
}

provider "proxmox" {
  # Configuration options
  pm_api_url          = "https://192.168.1.50:8006/api2/json"
  pm_api_token_id     = "mttaggart@pam!mttaggart"
  pm_api_token_secret = "9525cd7a-66cc-4df9-9bd3-f87e9b0ca2d3" 
  pm_tls_insecure     = true
  pm_log_enable       = true
}

resource "proxmox_vm_qemu" "demo-ws" {
  cores       = 2
  memory       = 4096
  name        = "WS-TF-Demo"
  target_node = "starbase"
  clone       = "seclab-win-ws"
  full_clone  = false

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
