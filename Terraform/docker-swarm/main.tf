terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.71.0"
    }
    keepass = {
      source = "iSchluff/keepass"
      version = "1.0.1"
    }
  }
}

variable "keepass_password" {
  type       = string
  sensitive  = true
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

provider "keepass" {
  password = "${var.keepass_password}"
}

data "keepass_entry" "proxmox_api" {
  path = "Passwords/Seclab/proxmox_api"
}

data "keepass_entry" "seclab_user" {
  path = "Passwords/Seclab/seclab_user"
}

provider "proxmox" {
  # Configuration options
  endpoint  = "https://${var.proxmox_host}:8006/api2/json"
  insecure  = true
  api_token = "${data.keepass_entry.proxmox_api.username}=${data.keepass_entry.proxmox_api.password}"
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
    user     = data.keepass_entry.seclab_user.username
    password = data.keepass_entry.seclab_user.password
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
    user     = data.keepass_entry.seclab_user.username
    password = data.keepass_entry.seclab_user.password
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
