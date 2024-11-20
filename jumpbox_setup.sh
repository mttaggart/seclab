#!/bin/bash

VSCODE_URL='https://update.code.visualstudio.com/latest/linux-deb-x64/stable'
VIVALDI_URL='https://downloads.vivaldi.com/stable/vivaldi-stable_6.6.3271.48-1_amd64.deb'

install_tools() {
	echo "[+] Installing baseline tools"
	sudo apt update
	sudo apt install -y tmux vim-gtk3 terminator krdc fish openssh-server sshpass wireshark fonts-liberation xrdp genisoimage
}

install_vscode() {
	echo "[+] Installing Visual Studio Code"
	wget -O code.deb $VSCODE_URL
	sudo dpkg -i code.deb
	rm code.deb
}

install_vivaldi() {
	echo "[?] Install Vivaldi Browser [y/N]? "
	read vivaldi_confirm
	if [[ $vivaldi_confirm == "y" ]] || [[ $vivaldi_confirm == "Y" ]]; then
		echo "[+] Installing Vivaldi"
		wget -O vivaldi.deb $VIVALDI_URL
		sudo dpkg -i vivaldi.deb
		sudo apt --fix-broken install -y
		rm vivaldi.deb
	fi
}

install_hashicorp() {
	echo "[+] Setting up Hashicorp Repository"
	wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null
	echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
	sudo apt update
	echo "[+] Installing Hashicorp Tools"
	sudo apt install -y packer terraform vault
}

install_ansible() {
	echo "[+] Installing Pip"
	sudo apt install -y python3-pip
	echo "[+] Installing Ansible"
	pip3 install ansible hvac
	echo "[+] Installing Ansible Galaxy Plugins"
	ansible-galaxy collection install community.docker community.hashi_vault community.windows community.general microsoft.ad
}

install_nerdfont() {
	echo "[+] Installing NerdFont"
	wget -O /tmp/scp.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/SourceCodePro.zip
	unzip /tmp/scp.zip -d /tmp/scp '*.ttf'
	sudo mkdir /usr/share/fonts/saucecode-pro
	sudo mv /tmp/scp/*.ttf /usr/share/fonts/saucecode-pro
	rm -rf /tmp/scp
	sudo fc-cache -s -f
}

install_fish() {
	printf "[?] Do you want to configure fish as your default shell [Y/n]? "
	read fish_confirm
	if [[ $fish_confirm == "" ]] || [[ $fish_confirm == "Y" ]] || [[ $fish_confirm == "y" ]]; then
		echo "[!] This is going to kick you into a fish shell. Type 'exit' to close it and continue installation. The final step will mess up this terminal session. Once it's finished, close it and open a new one."
		echo "[!] To enter Fish automatically, log out and back in."
		chsh -s /usr/bin/fish
		insall_nerdfont
		echo "[+] Configuring Terminator"
		cp ./terminatorconfig ~/.config/terminator/config
		echo "[+] Configuring Fish"
		# Starship
		curl -sS https://starship.rs/install.sh | sh
		mkdir ~/.config/fish
		echo "starship init fish | source" >~/.config/fish/config.fish
		cp ./fish_variables/.config/fish
		echo "[+] Configuring Starship"
		cp ./starship.toml ~/.config/starship.toml
		# OMF
		# curl -kL https://get.oh-my.fish | fish
		# fish -c "omf install bobthefish && exit"
	fi
}

initialize_vault() {
	echo "[+] Setting up Vault"
	cd Vault
	unset VAULT_TOKEN
	echo "[+] Creating Vault Systemd Service"
	sudo cp /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.bak
	sudo cp vault.hcl /etc/vault.d/vault.hcl
	# sudo cp vault.service /etc/systemd/system/vault.service
	echo "[+] Enabling Vault Systemd Service"
	sudo systemctl enable vault.service
	echo "[+] Starting Vault Systemd Service"
	sudo systemctl start vault.service
	echo "[+] Initializing Vault"
	echo "[+] Waiting for Vault service to be available..."
	sleep 10
	echo "[+] This command will output data that you MUST store elsewhere!"
	export VAULT_ADDR="http://127.0.0.1:8200"
	vault operator init
	echo "[+] Unsealing Vault"
	echo "[+] You will be prompted to enter 3 unseal keys in order."
	printf "[!] Press any key when ready"
	read vault_confirm
	for i in $(seq 3); do
		vault operator unseal
	done
	echo "[+] Logging in to Vault"
	printf "[?] Enter the Vault Root Token (You'll be asked for it again): "
	read vault_token
	export VAULT_TOKEN=$vault_token
	vault login
	echo "[+] Initializing KV Secrets Engine"
	vault secrets enable -version=2 -path=seclab kv
	cd ..
}

create_creds() {

	create_ssh_key() {
		echo "[+] Creating Lab Credentials"
		if [ ! -f ~/.ssh/id_rsa.pub ]; then
			echo "[+] Generating SSH Key"
			ssh-keygen -f ~/.ssh/id_rsa -b 4096 -P ''
		fi
	}
	get_proxmox_api_id() {
		printf "[?] Enter the Proxmox API Token ID: "
		read proxmox_api_id
	}
	get_proxmox_api_token() {
		printf "[?] Enter the Proxmox API Token Secret: "
		read proxmox_api_token
	}
	get_seclab_user() {
		printf "[?] Enter the default lab username: "
		read seclab_user
	}
	get_seclab_password() {
		printf "[?] Enter the default lab password: "
		read seclab_password
		printf "[?] Confirm the default lab password: "
		read seclab_password_confirm
		if [ $seclab_password != $seclab_password_confirm ]; then
			echo "[!] Passwords don't match!"
			get_seclab_password
		fi
	}
	get_seclab_windows_password() {
		printf "[?] Enter the default lab Windows password: "
		read seclab_windows_password
		printf "[?] Confirm the default lab Windows password: "
		read seclab_windows_password_confirm
		if [ $seclab_windows_password != $seclab_windows_password_confirm ]; then
			echo "[!] Passwords don't match!"
			get_seclab_windows_password
		fi
	}
	get_seclab_windows_domain_password() {
		printf "[?] Enter the lab Windows domain admin password: "
		read seclab_windows_domain_password
		printf "[?] Confirm the default lab Windows domain admin password: "
		read seclab_windows_domain_password_confirm
		if [ $seclab_windows_domain_password != $seclab_windows_domain_password_confirm ]; then
			echo "[!] Passwords don't match!"
			get_seclab_windows_domain_password
		fi
	}

	create_ssh_key
	get_seclab_user
	get_proxmox_api_id
	get_proxmox_api_token
	get_seclab_password
	get_seclab_windows_password
	get_seclab_windows_domain_password

	echo "[+] Setting the following:"
	echo "[!] Seclab user: $seclab_user"
	echo "[!] Seclab password: $seclab_password"
	echo "[!] Seclab Windows password: $seclab_windows_password"
	echo "[!] Seclab Windows Domain Admin password: $seclab_windows_domain_password"
	printf "[?] Does this look correct [Y/n]? "
	read create_creds_confirm
	if [[ $create_creds_confirm == "n" ]]; then
		echo "[!] Restarting credential wizard..."
		create_creds
	fi
	echo "[+] Setting Vault data"
 	USER_HOME_DIR=$(getent passwd "$USER" | cut -d: -f6)
	vault kv put -mount=seclab seclab proxmox_api_id=$proxmox_api_id proxmox_api_token=$proxmox_api_token seclab_user=$seclab_user seclab_password=$seclab_password seclab_windows_password=$seclab_windows_password seclab_windows_domain_password=$seclab_windows_domain_password seclab_ssh_key=@$USER_HOME_DIR/.ssh/id_rsa.pub
}

append_rcs() {
	echo "export VAULT_TOKEN=$vault_token" >>~/.bashrc
	echo "export VAULT_ADDR='http://127.0.0.1:8200'" >>~/.bashrc
	echo "export PATH=$PATH:~/.local/bin" >>~/.bashrc
	if [[ $fish_confirm == "" ]] || [[ $fish_confirm == "Y" ]] || [[ $fish_confirm == "y" ]]; then
		mkdir ~/.config/fish
		echo "set -x VAULT_TOKEN $vault_token" >>~/.config/fish/config.fish
		echo "set -x VAULT_ADDR 'http://127.0.0.1:8200'" >>~/.config/fish/config.fish
		echo "set -x PATH $PATH ~/.local/bin" >>~/.config/fish/config.fish
	fi
	source ~/.bashrc
}

echo "                                                                                          
     █████████████ ████████████   ████████████ █████            ███████    █████████████  
    ██████████████ ████████████ ██████████████ ████            ████████    ██████████████ 
                                                                                          
    ████████████  ████████████  ████          █████          █████ ████   █████████████   
           ██████ █████        █████          ████          █████  █████ █████    █████   
   █████████████ █████████████ █████████████  ████████████ █████████████ ██████████████   
  █████████████  ████████████  █████████████ █████████████ ████    █████ █████████████    
                                                                                          "

echo "This script will install dependencies for Seclab Jumpbox."
printf "Continue [Y/n]? "
read confirm

if [[ $confirm == "" ]] || [[ $confirm == "Y" ]]; then
	echo "Doing it"
	echo "[+] Beginning installation"
	install_tools
	install_vscode
	install_vivaldi
	install_hashicorp
	install_ansible
	initialize_vault
	create_creds
	install_fish
	append_rcs
	echo "[+] Setup finished! Time to configure Proxmox credentials!"
else
	exit 0
fi
