import argparse
import subprocess
import sys

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
    if args.vm_type not in VM_TYPES:
        print(f"{args.vm_type} not one of the valid VM Types!")
        sys.exit(-1)

def main():
    # Set up arg parser
    parser = argparse.ArgumentParser(description="Manage the Seclab assets")
    subparsers = parser.add_subparsers(help="Subcommands")
    parser_init = subparsers.add_parser("init", help="initialize the pfsense/ansible/servers")
    parser_add = subparsers.add_parser("add", help="add vm to the lab")
    parser_add.add_argument("vm_type", help="One of available Packer images")
    parser_add.add_argument("vm_name", help="name of VM")
    parser_add.set_defaults(func=add_vm)
    parser_remove = subparsers.add_parser("remove", help="remove vm from the lab")

    # Do the thing
    args = parser.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
