resource "proxmox_virtual_environment_vm" "lab-server" {
  for_each = toset([
    for i in range(1, var.num_servers + 1) : "${upper(split(".", var.domain)[0])}-SERV-${i}"
  ])
  name      = each.key
  node_name = var.proxmox_host
  on_boot   = true
  pool_id   = proxmox_virtual_environment_pool.zeroday_pool.pool_id

  clone {
    vm_id = var.server_template_id
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

  connection {
    type            = "ssh"
    user            = data.keepass_entry.seclab_windows.username
    password        = data.keepass_entry.seclab_windows.password
    host            = self.ipv4_addresses[0][0]
    target_platform = "windows"
  }


  provisioner "remote-exec" {
    inline = [
      "powershell.exe -c Rename-Computer '${each.key}'",
      "ipconfig"
    ]
  }

}



output "server_ips" {
  value = {
    for k, v in proxmox_virtual_environment_vm.lab-server : k => v.ipv4_addresses
  }
  sensitive   = false
  description = "Windows Hosts IPs"
}
