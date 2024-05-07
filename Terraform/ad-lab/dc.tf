variable "dc_hostname" {
  type        = string
  default     = "ZD-DC-01"
  description = "description"
}

resource "proxmox_virtual_environment_vm" "zd-dc" {
  name      = "ZD-DC-01"
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
    user            = data.vault_kv_secret_v2.seclab.data.seclab_user
    password        = data.vault_kv_secret_v2.seclab.data.seclab_windows_password
    host            = self.ipv4_addresses[0][0]
    target_platform = "windows"
  }


  provisioner "remote-exec" {
    inline = [
      "powershell.exe -c Rename-Computer '${var.dc_hostname}'",
      "powershell.exe -c Start-Service W32Time",
      "powershell.exe -c New-NetIpAddress -InterfaceAlias 'Ethernet 2' -IpAddress 10.1.99.3 -PrefixLength 24",
      "W32tm /resync /force",
      "ipconfig"
    ]
  }

}

output "zd_dc_ip" {
  value       = proxmox_virtual_environment_vm.zd-dc.ipv4_addresses
  sensitive   = false
  description = "AD Lab DC IP"
}

