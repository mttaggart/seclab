variable "fs_hostname" {
  type        = string
  default     = "ZD-FS-01"
  description = "username"
}

resource "proxmox_virtual_environment_vm" "zd-fs" {
  name      = "ZD-FS-01"
  node_name = var.proxmox_host
  on_boot   = true
  pool_id   = proxmox_virtual_environment_pool.zeroday_pool.pool_id

  clone {
    vm_id = var.fs_template_id
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

  connection {
    type            = "ssh"
    user            = data.keepass_entry.seclab_windows.username
    password        = data.keepass_entry.seclab_windows.password
    host            = self.ipv4_addresses[1][0]
    target_platform = "windows"
  }


  provisioner "remote-exec" {
    inline = [
      "powershell.exe -c Rename-Computer '${var.fs_hostname}'",
      "ipconfig"
    ]
  }

}

output "zd_fs_ip" {
  value       = proxmox_virtual_environment_vm.zd-fs.ipv4_addresses
  sensitive   = false
  description = "AD Lab Server IP"
}

