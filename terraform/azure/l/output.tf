output "vizix_mojix_hosts" {
  value = "\n${azurerm_public_ip.host1.ip_address}\n${azurerm_public_ip.host2.ip_address}\n${azurerm_public_ip.host3.ip_address}\n${azurerm_public_ip.host4.ip_address}\n${azurerm_public_ip.host5.ip_address}\n"
}

output "itermocil" {
  value = "\nwindows:\n  - name: ${var.resource_group_name}\n    root: ~/Dropbox*/Ke*/\n    layout: main-vertical\n    panes:\n      - ssh -i KEYNAME.pem ${var.username}@${azurerm_public_ip.host1.ip_address}\n      - ssh -i KEYNAME.pem ${var.username}@${azurerm_public_ip.host2.ip_address}\n      - ssh -i KEYNAME.pem ${var.username}@${azurerm_public_ip.host3.ip_address}\n      - ssh -i KEYNAME.pem ${var.username}@${azurerm_public_ip.host4.ip_address}\n      - ssh -i KEYNAME.pem ${var.username}@${azurerm_public_ip.host5.ip_address}"
}
