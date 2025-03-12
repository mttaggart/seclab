#!/bin/bash

# This stupid script is necessary because stupid Packer won't
# stupid prompt for stupid sensitive variables. Because it's stupid.

KPXC_DB_PATH=~/seclab/seclab.kdbx

echo "[+] Enter KeePass database password: "
read -s keepass_password
echo "[+] Running packer $@ ."
PKR_VAR_keepass_password=$keepass_password packer $@ .
