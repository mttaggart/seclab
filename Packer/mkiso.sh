#!/bin/bash

echo "[+] Extracting Vault Secrets"
printf "[?] Login to Vault? [y/N]"
read vault_login
if [[ $vault_login == "y" ]]; then
    vault login
fi
seclab_user=$(vault kv get -field=seclab_user seclab/seclab)
windows_pw=$(vault kv get -field=seclab_windows_password seclab/seclab)
echo "[+] Backing up Autounattend file"
cp -R $1 $1.bak
echo "[+] Injecting password"
sed -i "s/SECLAB_WINDOWS_PASSWORD/$windows_pw/g" $1/autounattend.xml
sed -i "s/SECLAB_USER/$seclab_user/g" $1/autounattend.xml
echo "[+] Making ISO"
mkisofs -J -l -R -V "Autounattend" -iso-level 4 -o Autounattend.iso $1
echo "[+] Cleaning up"
rm -rf $1
mv $1.bak $1
exit 0

