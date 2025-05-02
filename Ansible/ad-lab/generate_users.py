#!/usr/bin/env python3

import random
import sys
import json
import secrets
import os

os.chdir("ad-lab")

FIRST_NAMES_FILE = "./first_names.txt"
LAST_NAMES_FILE = "./last_names.txt"
USERS_OUTFILE = "./users.json"

# Use command line arg for num_users, or default to 10
try:
    num_users = int(sys.argv[1])
except:
    num_users = 10

# Load First Names
with open(FIRST_NAMES_FILE) as f:
    first_names = [l.strip() for l in f.readlines()]

# Load Last Names
with open(LAST_NAMES_FILE) as f:
    last_names = [l.strip() for l in f.readlines()]

def gen_user():
    first_name = random.choice(first_names)
    last_name = random.choice(last_names)
    username = f"{first_name[0].lower()}.{last_name.lower()}"
    display_name = f"{last_name}, {first_name}"
    password = secrets.token_urlsafe()
    return {
        "first_name": first_name,
        "last_name": last_name,
        "username": username,
        "display_name": display_name,
        "password": password
    }

users = [gen_user() for i in range(num_users)]

# Write users
with open(USERS_OUTFILE, "w") as f:
    json.dump(users, f, indent=4)
