# Packer

Packer is used to create virtual machine templates in the Proxmox lab. It relies on install `.iso` files for a given operating system, which must be sourced, uploaded to the Proxmox server, and the SHA256 hash modified in each respective `config.hcl` here.

## Ubuntu Server Templates

The Ubuntu server templates have a cloud-init feature that allows the preinstallation of packages. Modify the `user-data` file as desired.

These templates also make use of the `init-cloud-init.sh` script to populate the cloud-init files with your secrets from Vault. Do this before building your templates!

## Windows Templates

Windows builds are automated with an `autounattend.xml` file that must be mounted as a separate disk during installation. This is accounted for the in the `config.hcl`, but the username password are not stored in the XML files in the repo. Instead, `mkiso.sh` will pull the secrets from Vault for you.

The new `.iso` must be uploaded to Proxmox and named appropriately (see the `config.hcl`) for use. The SHA256 hash must also match.

Windows also requires the VirtIO drivers and QEMU Guest Agent which can be found in `.iso` files hosted [here](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/?C=M;O=D). Download the latest version as `virtio.iso`. Update the hash in the config files and upload to Proxmox.