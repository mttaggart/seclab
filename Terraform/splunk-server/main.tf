terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.11"
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
  default     = "seclab-splunk"
  description = "description"
}

variable "username" {
  type        = string
  default     = "seclab"
  description = "username"
}

variable "password" {
  type        = string
  default     = "seclab"
  description = "password"
}



provider "proxmox" {
  # Configuration options
  pm_api_url      = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure = true
  pm_log_enable   = true
}

resource "proxmox_vm_qemu" "seclab-splunk" {
  cores       = 4
  memory      = 8192
  name        = "Seclab-Splunk"
  target_node = var.proxmox_host
  clone       = "seclab-ubuntu-server-22-04"
  full_clone  = false
  onboot      = true
  agent       = 1

  connection {
    type = "ssh"
    user = "${var.username}"
    password = "${var.password}"
    host = self.default_ipv4_address
  }

  disk {
    type    = "virtio"
    size    = "50G"
    storage = "local-lvm"
  }

  network {
    bridge = "vmbr1"
    model  = "e1000"
  }
  network {
    bridge = "vmbr2"
    model  = "e1000"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hostname",
      "sudo hostname ${var.hostname}",
      "ip a s"
    ]
  }


}

output "vm_ip" {
  value       = proxmox_vm_qemu.seclab-splunk.default_ipv4_address
  sensitive   = false
  description = "VM IP"
}