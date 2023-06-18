# Seclab

This repo aims to provide a lightly-automated starting point for creating virtual labs for security research. To accomplish this, we rely on 4 technologies:

* **Proxmox**: Hypervisor/VM Host
* **Packer**: Base VM template creation
* **Terraform**: VM/VM set creation/destruction
* **Ansible**: VM post-provisioning

## Getting Started

Before cloning this repo, make sure you have:

1. A dedicated [Proxmox](https://www.proxmox.com) server.
2. `openvswitch` installed.
3. A jumpbox on the Proxmox server
4. Packer, Terraform, and Ansible installed.