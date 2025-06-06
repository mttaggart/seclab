variable "keepass_password" {
  type      = string
  sensitive = true
  ephemeral = true
}

variable "keepass_database" {
  type    = string
  default = "../../seclab.kdbx"
}

variable "region" {
  type    = string
  default = "sfo1"
}

variable "image" {
  type    = string
  default = "ubuntu-24-04-x64"
}

variable "size" {
  type    = string
  default = "s-1vcpu-1gb"
}


variable "hostname" {
  type    = string
  default = "dmz-relay"
}

variable "wg_port" {
  type    = number
  default = 51888
}

data "keepass_entry" "do_terraform_token" {
  path = "Passwords/Seclab/do_terraform_token"
}

data "keepass_entry" "seclab_user" {
  path = "Passwords/Seclab/seclab_user"
}

data "keepass_entry" "seclab_ssh_key" {
  path = "Passwords/Seclab/seclab_ssh_key"
}

data "http" "ipify" {
  url = "https://api.ipify.org"
}
