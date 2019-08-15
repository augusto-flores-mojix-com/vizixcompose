output "server_address" {
  value = "${digitalocean_droplet.server.*.ipv4_address}"
}
