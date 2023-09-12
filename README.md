# Seclab

The code accompaniment to the book [_The Homelab Almanac_](https://taggartinstitute.org/p/the-homelab-almanac), by Michael Taggart.

This repo aims to provide a lightly-automated starting point for creating virtual labs for security research. To accomplish this, we rely on 4 technologies:

* **Proxmox**: Hypervisor/VM Host
* **Packer**: Base VM template creation
* **Terraform**: VM/VM set creation/destruction
* **Vault**: Secrets management
* **Ansible**: VM post-provisioning

## Intended Usage

While this repo can be used independently, it is designed to be used in conjunction with _The Homelab Almanac_. If you find this repo useful, consider purchasing the book. If you already have, thank you so much!

## Getting Started

Before cloning this repo, make sure you have:

1. A dedicated [Proxmox](https://www.proxmox.com) server.
2. `openvswitch` installed.
3. A jumpbox on the Proxmox server.
4. Packer, Terraform, Vault, and Ansible installed, ideally on the jumpbox.

Some assembly required. These steps meant are meant to be executed on a Debian/Ubuntu jumpbox within a Proxmox hypervisor. Full details are in the book, but here are the basic steps.

## Steps

1. Generate a Proxmox API key with permission to create VMs.
2. Save the username and API Token for use in the next step.
3. Run `jumpbox_setup.sh` to set up the requisite tools. This installs Packer, Terraform, Vault, and Ansible, and sets up your Vault server.
4. Use [Packer](Packer/README.md) to create VM templates for your lab. The `mkiso.sh` and `init-cloud-init.sh` scripts ensure your static files never contain unencrypted secrets. You'll need OS install disks and the VirtIO disk (instructions provided).
5. Use [Terraform](Terraform/README.md) to provision VMs. The provided plans are good starting points.
4. Use [Ansible](Ansible/README.md) to create an inventory and provision your VMs with the provided playbooks—or your own!

## Contributing

Pull requests will be considered, but this project is intended as a directed project from [The Taggart Institute](https://taggartinstitute.org), and as such we reserve the right to accept/reject PRs based on project direction.

## Support

For support using this repo, join our [Discord](https://discord.gg/QRqEqEUqHC)! We'd love to have you in our learning community.
