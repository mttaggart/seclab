#!/bin/bash

install_vscode() {
    echo "[+] Installing Visual Studio Code"
    wget 'https://az764295.vo.msecnd.net/stable/695af097c7bd098fbf017ce3ac85e09bbc5dda06/code_1.79.2-1686734195_amd64.deb' -O code.deb
    sudo dpkg -i code.deb
    rm code.deb
}

install_vivaldi() {
    echo "[+] Installing Vivaldi"
    wget -O vivaldi.deb https://downloads.vivaldi.com/stable/vivaldi-stable_6.1.3035.100-1_amd64.deb
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
    printf "[!] Do you want to configure fish as your default shell?"
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
    echo "[+] This will create a vault_creds.txt file that you MUST remove and store elsewhere!"
    vault operator init | tee vault_creds.txt
    echo "[+] Unsealing Vault"
    echo "[+] You will be prompted to enter 3 unseal keys in order."
    printf "[+] Press any key when ready"
    read vault_confirm
    for i in $(seq 3); do
        vault operator unseal
    done
    echo "[+] Logging in to Vault"
    echo "[+] You will be prompted to enter the Vault root token. Get it ready."
    printf "[+] Press any key when ready"
    read vault_confirm
    vault login

    
}

create_creds() {
    echo "[+] Creating Lab Credentials"
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
    install_fish
else
    exit 0
fi

