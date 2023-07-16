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
  default     = "seclab-docker"
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


resource "proxmox_vm_qemu" "seclab-docker-main" {
  cores       = 2
  memory      = 4096
  name        = "Docker-Demo-Main"
  target_node = var.proxmox_host
  clone       = "seclab-ubuntu-server-22-04"
  full_clone  = false
  onboot      = true
  agent       = 1

  connection {
    type = "ssh"
    user = data.vault_kv_secret_v2.seclab.data.seclab_user
    password = data.vault_kv_secret_v2.seclab.data.seclab_password
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
  clone       = "seclab-ubuntu-server-22-04"
  full_clone  = false
  onboot      = true
  agent       = 1

  connection {
    type = "ssh"
    user = data.vault_kv_secret_v2.seclab.data.seclab_user
    password = data.vault_kv_secret_v2.seclab.data.seclab_password
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