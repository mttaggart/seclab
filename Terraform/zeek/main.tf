terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.48.1"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.16.0"
    }
  }
}

variable "proxmox_host" {
  type        = string
  default     = "proxmox"
  description = "Proxmox node name"
}

variable "hostname" {
  type        = string
  default     = "seclab-zeek"
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


resource "proxmox_virtual_environment_vm" "seclab-zeek" {
  name      = "Seclab-zeek"
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
    bridge = "vmbr2"
    model  = "e1000"
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


  provisioner "file" {
    source      = "./00-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak",
      "sudo mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostnamectl hostname ${var.hostname}",
      "sudo netplan apply && sudo ip addr add dev ens18 ${self.ipv4_addresses[1][0]}",
      "ip a s"
    ]
  }


}

output "vm_ip" {
  value       = proxmox_virtual_environment_vm.seclab-zeek.ipv4_addresses
  sensitive   = false
  description = "VM IP"
}
