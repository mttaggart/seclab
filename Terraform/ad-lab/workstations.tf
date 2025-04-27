resource "proxmox_virtual_environment_vm" "lab-workstation" {
  for_each  = toset([
    for i in range(1, var.num_workstations+1): "${ upper(split(".", var.domain)[0]) }-WS-${i}"
  ])
  name      = each.key
  node_name = var.proxmox_host
  on_boot   = true
  pool_id   = proxmox_virtual_environment_pool.zeroday_pool.pool_id
  
  clone {
    vm_id = var.workstation_template_id
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
      "powershell.exe -c Rename-Computer '${each.key}'",
      "ipconfig"
    ]
  }

}

output "workstation_ips" {
  value = {
    for k,v in proxmox_virtual_environment_vm.lab-workstation : k => v.ipv4_addresses
  }
  sensitive   = false
  description = "Windows Hosts IPs"
}
