output "server_address" {
  value = ["${packet_device.server.network}"]

  # value = ["${packet_device.server.*.network.0.address}"]
}
