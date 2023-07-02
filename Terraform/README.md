# Terraform

Terraform provisions virtual machines based on templates that have been created via Packer. All secrets are pulled from Vault.

As long as the environment variables listed at the root [Readme](../README.md) are in place and the VM template names match, these plans should work as-is. Simply:

```bash
tf init
tf apply
```

Assuming all the secrets are correct, you'll soon have deployed virtual machines on the Proxmox node!