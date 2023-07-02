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
  default     = "seclab-soc"
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
  pm_api_url          = "https://${var.proxmox_host}:8006/api2/json"
  pm_tls_insecure     = true
  pm_log_enable       = true
}

resource "proxmox_vm_qemu" "seclab-soc" {
  cores       = 4
  memory      = 8192
  name        = "Seclab-SOC"
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
  network {
    bridge = "vmbr2"
    model = "e1000"
    # Default, but explicit for pcap
    firewall = false
  }


  provisioner "file" {
    source      = "./00-netplan.yaml"
    destination = "/tmp/00-netplan.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hosts",
      "sudo sed -i 's/seclab-ubuntu-server/${var.hostname}/g' /etc/hostname",
      "sudo mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak",
      "sudo mv /tmp/00-netplan.yaml /etc/netplan/00-netplan.yaml",
      "sudo hostname ${var.hostname}",
      "sudo netplan apply && sudo ip addr add dev ens18 ${self.default_ipv4_address}",
      "ip a s"
    ]
  }


}

output "vm_ip" {
  value       = proxmox_vm_qemu.seclab-soc.default_ipv4_address
  sensitive   = false
  description = "VM IP"
}