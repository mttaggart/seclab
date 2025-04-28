
variable "dc_ip" {
  type        = string
  default     = "10.1.99.3"
  description = "DC IP Address"
}

locals {
  dc_hostname = "${upper(split(".", var.domain)[0])}-DC-01"
}

resource "proxmox_virtual_environment_vm" "dc" {
  name      = local.dc_hostname
  node_name = var.proxmox_host
  on_boot   = true
  pool_id   = proxmox_virtual_environment_pool.zeroday_pool.pool_id

  clone {
    vm_id = var.dc_template_id
    full  = false
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr2"
    model  = "e1000"
  }

  network_device {
    bridge = "vmbr2"
    model  = "e1000"
  }

  connection {
    type            = "ssh"
    user            = data.keepass_entry.seclab_windows.username
    password        = data.keepass_entry.seclab_windows.password
    host            = self.ipv4_addresses[1][0]
    target_platform = "windows"
  }


  provisioner "remote-exec" {
    inline = [
      "powershell.exe -c Rename-Computer '${local.dc_hostname}'",
      "powershell.exe -c New-NetIpAddress -InterfaceAlias 'Ethernet 2' -IpAddress ${var.dc_ip} -PrefixLength 24",
      "ipconfig"
    ]
  }

}

output "dc_ip" {
  value       = proxmox_virtual_environment_vm.dc.ipv4_addresses
  sensitive   = false
  description = "AD Lab DC IP"
}

