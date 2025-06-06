output "server_ip" {
  description = "Relay public IP"
  value       = digitalocean_droplet.dmz-relay.ipv4_address
}
