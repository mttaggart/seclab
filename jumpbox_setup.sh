#!/bin/bash

VSCODE_URL='https://az764295.vo.msecnd.net/stable/695af097c7bd098fbf017ce3ac85e09bbc5dda06/code_1.79.2-1686734195_amd64.deb'
VIVALDI_URL='https://downloads.vivaldi.com/stable/vivaldi-stable_6.1.3035.100-1_amd64.deb'

install_vscode() {
    echo "[+] Installing Visual Studio Code"
    wget -O code.deb $VSCODE_URL 
    sudo dpkg -i code.deb
    rm code.deb
}

install_vivaldi() {
    echo "[+] Installing Vivaldi"
    wget -O vivaldi.deb $VIVALDI_URL
    sudo dpkg -i vivaldi.deb
    rm vivaldi.deb
}

install_hashicorp() {
    echo "[+] Setting up Hashicorp Repository"
    wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
    sudo apt update    
    echo "[+] Installing Hashicorp Tools"
    sudo apt install -y packer terraform vault
}

install_ansible() {
    echo "[+] Installing Ansible"
    pip3 install ansible
    echo "[+] Installing Ansible Galaxy Plugins"
    ansible-galaxy collection install community.docker community.hashi.vault community.windows community.general microsoft.ad
}

install_tools() {
    echo "[+] Installing other tools"
    sudo apt install -y tmux vim-gtk3 terminator krdc fish
}

install_fish() {
    printf "[?] Do you want to configure fish as your default shell?"
    read fish_confirm
    if [[ $fish_confirm == "" ]] || [[ $fish_confirm == "Y" ]]; then
        echo "[+] Installing Powerline fonts"
        current_dir=`pwd`
        mkdir ~/Scripts
        cd ~/Scripts
        git clone https://github.com/powerline/fonts
        cd fonts
        chmod +x install.sh
        ./install.sh
        cd $current_dir
        echo "[+] Configuring Terminator"
        cp ./terminatorconfig ~/.config/terminator/config
        echo "[+] Configuring Fish"
        curl -kL https://get.oh-my.fish | fish
        fish -c "omf install bobthefish && exit"
    fi
}

initialize_vault() {
    echo "[+] Setting up Vault"
    cd Vault
    unset VAULT_TOKEN
    export VAULT_ADDR='http://127.0.0.1:8200'
    echo "[+] Creating Vault Systemd Service"
    sudo cp /etc/vault.d/vault.hcl /etc/vault.d/vault.hcl.bak
    sudo cp config.hcl /etc/vault.d/vault.hcl
    sudo cp vault.service /etc/systemd/system/vault.service
    echo "[+] Enabling Vault Systemd Service"
    sudo systemctl enable vault.service
    echo "[+] Starting Vault Systemd Service"
    sudo systemctl start vault.service
    echo "[+] Initializing Vault"
    echo "[+] This command will output data that you MUST store elsewhere!"
    vault operator init
    echo "[+] Unsealing Vault"
    echo "[+] You will be prompted to enter 3 unseal keys in order."
    printf "[!] Press any key when ready"
    read vault_confirm
    for i in $(seq 3); do
        vault operator unseal
    done
    echo "[+] Logging in to Vault"
    printf "[?] Enter the Vault Root Token"
    read vault_token
    export VAULT_TOKEN=$vault_token
    vault login
    echo "[+] Initializing KV Secrets Engine"
    vault secrets enable -version=2 -path=seclab kv
}

create_creds() {
    echo "[+] Creating Lab Credentials"
    printf "[?] Enter the default lab username: "
    read seclab_username
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

    get_seclab_password
    get_seclab_windows_password
    get_seclab_windows_domain_password

    echo "[+] Setting the following:"
    echo "[!] Seclab username: $seclab_username"
    echo "[!] Seclab password: $seclab_password"
    echo "[!] Seclab Windows password: $seclab_windows_password"
    echo "[!] Seclab Windows Domain Admin password: $seclab_windows_domain_password"
    printf "[?] Does this look correct? [Y/n]"
    read create_creds_confirm
    if [ $create_creds_confirm == "n" ]; then
        echo "[!] Restarting credential wizard..."
        create_creds
    fi
    echo "[+] Setting Vault data"
    vault kv put -mount=seclab seclab seclab_user=$seclab_user seclab_password=$seclab_password seclab_windows_password=$seclab_windows_password seclab_windows_domain_password=$seclab_windows_domain_password
}

append_rcs() {
    echo "export VAULT_TOKEN=$vault_token" >> ~/.bashrc
    echo "export VAULT_ADDR='http://127.0.0.1:8200'" >> ~/.bashrc
    if [[ $fish_confirm == "" ]] || [[ $fish_confirm == "Y" ]]; then
        echo "set -x VAULT_TOKEN $vault_token" >> ~/.config/fish/config.fish
        echo "set -x VAULT_ADDR 'http://127.0.0.1:8200'" >> ~/.config/fish/config.fish
    fi
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
printf "Continue? [Y/n] "
read confirm

if [[ $confirm == "" ]] || [[ $confirm == "Y" ]]; then
    echo "Doing it"
    echo "[+] Beginning installation"
    install_vscode
    install_vivaldi
    install_hashicorp
    install_ansible
    install_tools
    initialize_vault
    create_creds
    install_fish
    append_rcs
    echo "[+] Setup finished! Time to configure Proxmox credentials!"
else
    exit 0
fi

