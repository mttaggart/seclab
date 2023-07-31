#! /bin/bash

echo "[+] Extracting Vault Secrets"
printf "[?] Login to Vault? [y/N]"
read vault_login
if [[ $vault_login == "y" ]]; then
    vault login
fi
seclab_user=$(vault kv get -field=seclab_user seclab/seclab)
seclab_pw=$(vault kv get -field=seclab_password seclab/seclab)
seclab_ssh_key=$(vault kv get -field=seclab_ssh_key seclab/seclab)
encrypted_pw=$(openssl passwd -6 $seclab_pw)
echo $encrypted_pw
echo "[+] Adding encrypted secret to user-data/preseed files"
for f in $(find ./ -name user-data -or -name "*.preseed"); do
    cp $f $f.bak
    sed -i "s/SECLAB_USER/$seclab_user/g" $f
    sed -i "s:SECLAB_PASSWORD:${encrypted_pw}:g" $f
    sed -i "s:SECLAB_SSH_KEY:$seclab_ssh_key:g" $f
done
exit 0