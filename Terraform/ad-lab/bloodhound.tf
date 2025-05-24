variable "bloodhound_hostname" {
  type    = string
  default = "bloodhound"
}


resource "proxmox_virtual_environment_vm" "ad-lab-bloodhound" {
  name      = "AD-Lab-Bloodhound"
  node_name = var.proxmox_host
  on_boot   = false
  pool_id   = proxmox_virtual_environment_pool.zeroday_pool.pool_id

  clone {
    vm_id = var.bloodhound_template_id
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
      "sudo hostnamectl hostname ${var.bloodhound_hostname}",
      "ip a s"
    ]
  }
}

output "bloodhound_ip" {
  value       = proxmox_virtual_environment_vm.ad-lab-bloodhound.ipv4_addresses
  sensitive   = false
  description = "AD Lab Bloodhound IP"
}
