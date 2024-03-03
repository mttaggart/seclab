#!/bin/bash

[[ -z $1 ]] && echo '[!] No directory target provided! Please provide a valid directory (e.g. scripts)' && exit 127

echo "[+] Extracting Vault Secrets"
printf "[?] Login to Vault? [y/N]"
read vault_login
if [[ $vault_login == "y" ]]; then
	vault login
fi

seclab_user=$(vault kv get -field=seclab_user seclab/seclab)
windows_pw=$(vault kv get -field=seclab_windows_password seclab/seclab)
windows_domain_pw=$(vault kv get -field=seclab_windows_domain_password seclab/seclab)

windows_userpw=$windows_pw"Password"
windows_adminpw=$windows_pw"AdministratorPassword"
windows_domain_adminpw=$windows_domain_pw"AdministratorPassword"

windows_userpw=$(echo -n $windows_userpw | iconv -f utf-8 -t utf16le | base64 -w0)
windows_adminpw=$(echo -n $windows_adminpw | iconv -f utf-8 -t utf16le | base64 -w0)
windows_domain_adminpw=$(echo -n $windows_domain_adminpw | iconv -f utf-8 -t utf16le | base64 -w0)

echo "[+] Backing up Autounattend file"
cp -R $1 $1.bak

echo "[+] Injecting password"
sed -i "s/SECLAB_WINDOWS_PASSWORD/$windows_userpw/g" $1/autounattend.xml
sed -i "s/SECLAB_WINDOWS_ADMIN_PASSWORD/$windows_adminpw/g" $1/autounattend.xml
sed -i "s/SECLAB_WINDOWS_DOMAIN_PASSWORD/$windows_domain_adminpw/g" $1/autounattend.xml
sed -i "s/SECLAB_USER/$seclab_user/g" $1/autounattend.xml

echo "[+] Making ISO"
new_iso="Autounattend-$(basename $PWD).iso"
genisoimage -J -l -R -V "Autounattend" -iso-level 4 -o ../$new_iso $1
echo "[+] Cleaning up"
rm -rf $1
mv $1.bak $1
echo "[+] Obtaining SHA256 Hash of New ISO"
sha256sum ../$new_iso
exit 0
