terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.10"
    }
  }
}

variable "proxmox_host" {
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
  default     = "seclab"
  description = "password"
}



provider "proxmox" {
  # Configuration options
  pm_api_url      = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure = true
  pm_log_enable   = true
}

resource "proxmox_vm_qemu" "seclab-docker-main" {
  cores       = 2
  memory      = 4096
  name        = "Docker-Demo-Main"
  target_node = var.proxmox_host
  clone       = "seclab-ubuntu-server-20-04"
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

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/seclab-ubuntu-server/seclab-docker-main/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-server/seclab-docker-main/g' /etc/hostname",
      "sudo hostname seclab-docker-main",
      "ip a s"
    ]
  }


}

resource "proxmox_vm_qemu" "seclab-docker-node" {
  cores       = 2
  memory      = 4096
  name        = "Docker-Demo-Node"
  target_node = var.proxmox_host
  clone       = "seclab-ubuntu-server-20-04"
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

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/seclab-ubuntu-server/seclab-docker-node/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-server/seclab-docker-node/g' /etc/hostname",
      "sudo hostname seclab-docker-node",
      "ip a s"
    ]
  }


}

output "docker-main-ip" {
  value       = proxmox_vm_qemu.seclab-docker-main.default_ipv4_address
  sensitive   = false
  description = "Docker Main IP"
}

output "docker-node-ip" {
  value       = proxmox_vm_qemu.seclab-docker-node.default_ipv4_address
  sensitive   = false
  description = "Docker Node IP"
}