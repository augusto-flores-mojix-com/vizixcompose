output "server_address" {
  value = ["${aws_instance.server.*.public_ip}"]
}

output "private_server_address" {
  value = ["${aws_instance.server.*.private_ip}"]
}
