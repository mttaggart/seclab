terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.68.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.5.0"
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
  default     = "seclab-kali"
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


resource "proxmox_virtual_environment_vm" "seclab-kali" {
  name      = "Seclab-Kali"
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
    cores = 4
  }

  memory {
    dedicated = 8192
  }

  network_device {
    bridge = "vmbr2"
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
      "ip a s"
    ]
  }


}

output "vm_ip" {
  value       = proxmox_virtual_environment_vm.seclab-kali.ipv4_addresses
  sensitive   = false
  description = "VM IP"
}
