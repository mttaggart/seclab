resource "digitalocean_firewall" "dmz-relay-fw" {
  name = "dmz-relay"
  droplet_ids = [digitalocean_droplet.dmz-relay.id]

  inbound_rule {
    protocol = "udp"
    port_range = "${var.wg_port}"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  inbound_rule {
    protocol = "tcp"
    port_range = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  
  inbound_rule {
    protocol = "tcp"
    port_range = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol = "tcp"
    port_range = "22"
    source_addresses = ["${data.http.ipify.response_body}"]
  }
  
}
