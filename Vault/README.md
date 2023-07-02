# Vault

This is how we manage secrets in the lab. If you're following along and have already run `jumpbox_setup.sh`, then your Vault contains the secrets you need.

If you haven't, I encourage you install Vault and review the [deployment documentation](https://developer.hashicorp.com/vault/tutorials/getting-started/getting-started-deploy). Once done, with an unsealed Vault, you'll need to decide on the following values:

* `seclab_user`: Management user account for all machines in the lab.
* `seclab_password`: Password for `seclab_user`.
* `seclab_windows_password`: Could be different than the default; make sure it meets minimum Windows password strength requirements!
* `seclab_windows_domain_password`: When we make Windows domains, this is the Domain Admin password.

Use Vault to initialize a new KV (version 2) secrets engine, at path `seclab`. Then set a new secret at `seclab` (so `seclab/seclab`) to the above respective keys and values.

Confused? Buy the book ;)

The idea of the Vault is to keep the necessary secrets for the lab, without storing them in cleartext in our files. Packer, Terraform, and Ansible all refer to this Vault. It must be unsealed for those components of the lab to work.