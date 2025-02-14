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

variable "hostname" {
  type        = string
  default     = "seclab-ws"
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
  path = "Passwords/Seclab/seclab_windows"
}

provider "proxmox" {
  # Configuration options
  endpoint  = "https://${var.proxmox_host}:8006/api2/json"
  insecure  = true
  api_token = "${data.keepass_entry.proxmox_api.username}=${data.keepass_entry.proxmox_api.password}"
}

resource "proxmox_virtual_environment_vm" "seclab-ws" {
  name      = "Seclab-Workstation"
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
  network_device {
    bridge = "vmbr2"
    model  = "e1000"
  }

  connection {
    type     = "ssh"
    user     = data.keepass_entry.seclab_user.username
    password = data.keepass_entry.seclab_user.password
    host     = self.ipv4_addresses[0][0]
    target_platform = "windows"
  }


  provisioner "remote-exec" {
    inline = [
      "powershell.exe -c Rename-Computer '${var.hostname}'",
      "ipconfig"
    ]
  }

}

output "vm_ip" {
  value       = proxmox_virtual_environment_vm.seclab-ws.ipv4_addresses
  sensitive   = false
  description = "VM IP"
}
