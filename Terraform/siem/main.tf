terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.13"
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
  description = "description"
}

variable "hostname" {
  type        = string
  default     = "seclab-siem"
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
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure     = true
  pm_log_enable       = true
  pm_api_token_id     = data.vault_kv_secret_v2.seclab.data.proxmox_api_id
  pm_api_token_secret = data.vault_kv_secret_v2.seclab.data.proxmox_api_token
}


resource "proxmox_vm_qemu" "seclab-siem" {
  cores       = 4
  memory      = 8192
  name        = "Seclab-SIEM"
  target_node = var.proxmox_host
  clone       = "seclab-ubuntu-22-04"
  full_clone  = false
  onboot      = true
  agent       = 1

  connection {
    type     = "ssh"
    user     = data.vault_kv_secret_v2.seclab.data.seclab_user
    password = data.vault_kv_secret_v2.seclab.data.seclab_password
    host     = self.default_ipv4_address
  }

  network {
    bridge = "vmbr1"
    model  = "e1000"
  }
  network {
    bridge = "vmbr2"
    model  = "e1000"
    # Default, but explicit for pcap
    firewall = false
  }


  provisioner "file" {
    source      = "./00-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/seclab-ubuntu-22-04/${var.hostname}/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-22-04/${var.hostname}/g' /etc/hostname",
      "sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak",
      "sudo mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostname ${var.hostname}",
      "sudo netplan apply && sudo ip addr add dev ens18 ${self.default_ipv4_address}",
      "ip a s"
    ]
  }


}

output "vm_ip" {
  value       = proxmox_vm_qemu.seclab-siem.default_ipv4_address
  sensitive   = false
  description = "VM IP"
}
