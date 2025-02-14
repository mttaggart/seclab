#! /bin/bash
KPXC_DB_PATH=~/seclab/seclab.kdbx
SSH_KEY_PATH=~/.ssh/id_rsa.pub

echo "[+] Extracting KPXC Secrets"
echo "[+] You'll be asked for your KeePassXC database password twice."
seclab_user=$(keepassxc-cli show -s $KPXC_DB_PATH Seclab/seclab_user | grep UserName | cut -d " " -f 2)
seclab_pw=$(keepassxc-cli show -s $KPXC_DB_PATH Seclab/seclab_user | grep Password | cut -d " " -f 2)
seclab_ssh_key=$(cat $SSH_KEY_PATH)
encrypted_pw=$(openssl passwd -6 $seclab_pw)
echo "[+] Moving example files to active files"
for f in $(find ./ -name "user-data.example" -or -name "*.preseed.example"); do
	cp $f "${f%.example}"
done
echo $encrypted_pw
echo "[+] Adding encrypted secret to user-data/preseed files"
for f in $(find ./ -name "user-data" -or -name "*.preseed"); do
	cp $f $f.bak
	sed -i "s/SECLAB_USER/$seclab_user/g" $f
	sed -i "s:SECLAB_PASSWORD:${encrypted_pw}:g" $f
	sed -i "s:SECLAB_SSH_KEY:$seclab_ssh_key:g" $f
done
exit 0
