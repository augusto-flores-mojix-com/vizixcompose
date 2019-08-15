output "vizix_mojix_hosts" {
  value = "${azurerm_public_ip.host1.ip_address}"
}

output "itermocil" {
  value = "\nwindows:\n  - name: ${var.resource_group_name}\n    root: ~/Dropbox*/Ke*/\n    layout: main-vertical\n    panes:\n      - ssh -i KEYNAME.pem ${var.username}@${azurerm_public_ip.host1.ip_address}"
}
