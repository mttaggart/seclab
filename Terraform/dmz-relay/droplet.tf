resource "digitalocean_droplet" "dmz-relay" {
  image  = var.image
  name   = var.hostname
  region = var.region
  size   = var.size
  user_data = templatefile(
    "./user-data.tftpl",
    {
      username = data.keepass_entry.seclab_user.username,
      ssh_key  = base64decode(data.keepass_entry.seclab_ssh_key.username)
    }
  )
}
