terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.71.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.6.0"
    }
  }
}

variable "proxmox_host" {
  type        = string
  default     = "proxmox"
  description = "Proxmox node name"
}

variable "manager_hostname" {
  type        = string
  default     = "swarm-manager"
  description = "hostname"
}

variable "worker_hostname" {
  type        = string
  default     = "swarm-worker"
  description = "hostname"
}

variable "template_id" {
  type        = string
  description = "Template ID for clone"
}

provider "vault" {

}

data "vault_kv_secret_v2" "seclab" {
  mount = "seclab"
  name  = "seclab"
}

provider "proxmox" {
  # Configuration options
  endpoint  = "https://${var.proxmox_host}:8006/api2/json"
  insecure  = true
  api_token = "${data.vault_kv_secret_v2.seclab.data.proxmox_api_id}=${data.vault_kv_secret_v2.seclab.data.proxmox_api_token}"
}

resource "proxmox_virtual_environment_vm" "swarm-manager" {
  name      = "Swarm-Manager"
  node_name = var.proxmox_host
  on_boot   = true

  clone {
    vm_id = var.template_id
    full  = false
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr1"
    model  = "e1000"
  }

  connection {
    type     = "ssh"
    user     = data.vault_kv_secret_v2.seclab.data.seclab_user
    password = data.vault_kv_secret_v2.seclab.data.seclab_password
    host     = self.ipv4_addresses[1][0]
  }


  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl hostname ${var.manager_hostname}",
      "sudo netplan apply && sudo ip addr add dev ens18 ${self.ipv4_addresses[1][0]}",
      "ip a s"
    ]
  }
}

resource "proxmox_virtual_environment_vm" "swarm-worker" {
  name      = "Swarm-Worker"
  node_name = var.proxmox_host
  on_boot   = true

  clone {
    vm_id = var.template_id
    full  = false
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr1"
    model  = "e1000"
  }

  connection {
    type     = "ssh"
    user     = data.vault_kv_secret_v2.seclab.data.seclab_user
    password = data.vault_kv_secret_v2.seclab.data.seclab_password
    host     = self.ipv4_addresses[1][0]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl hostname ${var.worker_hostname}",
      "sudo netplan apply && sudo ip addr add dev ens18 ${self.ipv4_addresses[1][0]}",
      "ip a s"
    ]
  }
}

output "swarm_manager_ip" {
  value       = proxmox_virtual_environment_vm.swarm-manager.ipv4_addresses
  sensitive   = false
  description = "Swarm Manager IP"
}

output "swarm_worker_ip" {
  value       = proxmox_virtual_environment_vm.swarm-worker.ipv4_addresses
  sensitive   = false
  description = "Swarm Worker IP"
}
