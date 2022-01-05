import argparse
import subprocess
import sys
import os
import shutil
import logging

"""
Args:

init: Initializes the pfsense/ansible servers
add [vm-type] [vm-name]: Builds and adds the given vm
remove [vm-name]: Removes the given vm
"""

# Constants
VM_TYPES = [
    "win-server",
    "win-ws",
    "jumpbox",
    "labbuntu" # TODO: Change this
]

PFSENSE_NAME = "pfsense",
ANSIBLE_NAME = "ansible"

def add_vm(args):
    vm_type = args.vm_type
    vm_name = args.vm_name
    if vm_type not in VM_TYPES:
        print(f"{vm_type} not one of the valid VM Types!")
        sys.exit(-1)
    
    if shutil.which("packer"):
        os.chdir(f"{vm_type}-packer")
        config_base = "config.pkr.hcl"
        config_copy = "config.copy.pkr.hcl"
        vars_base = "variables.pkrvars.hcl"
        vars_copy = "variables.copy.pkrvars.hcl"
        shutil.copyfile(vars_base, vars_copy)

        # Replace stuff
        subprocess.run(f"sed -i s/seclab-{vm_type}/{vm_name}/g {config_copy}".split(" "))
        subprocess.run(f"sed -i s/seclab-{vm_type}/{vm_name}/g {vars_copy}".split(" "))
        packer_build = subprocess.run(f"packer build -force -var-file={vars_copy} .".split(" "))
        
        # On successful build, import the resulting OVA
        if packer_build.returncode == 0:
            subprocess.run(f"vboxmanage import output-{vm_name}/{vm_name}.ova".split(" "))
        else:
            logging.critical("Could not build VM! Check Packer errors above")
        os.remove(vars_copy)
        os.remove(config_copy)
    else:
        logging.error("Packer not installed!")

def remove_vm(args):
    vm_name = args.vm_name
    subprocess.run(f"vboxmanage unregistervm --delete {vm_name}".split(" "))

def main():
    # Set up arg parser
    parser = argparse.ArgumentParser(description="Manage the Seclab assets")
    subparsers = parser.add_subparsers(help="Subcommands")
    
    # seclab.py init
    parser_init = subparsers.add_parser("init", help="initialize the pfsense/ansible/servers")
    
    # seclab.py add [vm_type] [vm_name]
    parser_add = subparsers.add_parser("add", help="add vm to the lab")
    parser_add.add_argument("vm_type", help="One of available Packer images")
    parser_add.add_argument("vm_name", help="name of VM")
    parser_add.set_defaults(func=add_vm)
    
    # seclab.py remove [vm_name]
    parser_remove = subparsers.add_parser("remove", help="remove vm from the lab")
    parser_remove.add_argument("vm_name", help="name of VM to remove")

    # Do the thing
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
