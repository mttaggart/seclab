# Ansible

Ansible is our configuration management tool. After bringing up VMs with Terraform, Ansible playbooks are used to assign roles, install packages, and generally configure our machines for use.

## Inventory

The `inventory.example.d` folder shows a basic structure for the inventory. Copy this to a new `inventory` folder for your own usage. The repo won't track it by default, which is by design: I don't want you accidentally exposing your lab details on a public GH repo if you fork this.

The inventory is based on hostnames. Make sure these are added to your `/etc/hosts` file for them to resolve.