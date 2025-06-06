terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    keepass = {
      source  = "iSchluff/keepass"
      version = "1.0.1"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.5.0"
    }
  }
}

provider "keepass" {
  database = var.keepass_database
  password = var.keepass_password
}

provider "digitalocean" {
  token = data.keepass_entry.do_terraform_token.password
}

