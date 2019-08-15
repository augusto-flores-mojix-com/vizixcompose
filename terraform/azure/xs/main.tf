terraform {
  required_version = "> 0.10.8"
}

provider "azurerm" {
  subscription_id = "${var.azure_subscription_id}"
  client_id       = "${var.azure_client_id}"
  client_secret   = "${var.azure_client_secret}"
  tenant_id       = "${var.azure_tenant_id}"
}

resource "azurerm_resource_group" "kafkars" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_virtual_network" "kafkars" {
  name                = "main_vn"
  address_space       = ["10.100.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_subnet" "kafkars" {
  name                 = "main_subnet"
  resource_group_name  = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.kafkars.name}"
  address_prefix       = "10.100.2.0/24"
}

resource "azurerm_network_security_group" "kafkars" {
  name                = "main_security_group"
  location            = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
}

resource "azurerm_network_security_rule" "visualizer" {
  name                        = "Visualizer"
  priority                    = 210
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8001"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "http" {
  name                        = "HTTP"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "mqtt" {
  name                        = "MQTT"
  priority                    = 140
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "1883"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "graphana" {
  name                        = "Grafana"
  priority                    = 220
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "ftpp" {
  name                        = "FTP"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "21"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "cbba" {
  name                        = "CBBA"
  priority                    = 113
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "190.181.41.186/32"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "lpz1" {
  name                        = "lpz1"
  priority                    = 114
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "190.181.5.61/32"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "lpz2" {
  name                        = "lpz2"
  priority                    = 115
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "190.181.5.60/32"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "vpn" {
  name                        = "vpn"
  priority                    = 116
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "147.75.99.67/32"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "httpbridge" {
  name                        = "httpbridge"
  priority                    = 150
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9090"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "kafka" {
  name                        = "kafka"
  priority                    = 160
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9092"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "zookeeper" {
  name                        = "zookeeper"
  priority                    = 170
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "2181"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

resource "azurerm_network_security_rule" "https" {
  name                        = "https"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.kafkars.name}"
}

############################### host1 host ###################################
resource "azurerm_public_ip" "host1" {
  name                         = "host1_ip"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "host1_ni" {
  name                          = "host1_ni"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  network_security_group_id     = "${azurerm_network_security_group.kafkars.id}"
  enable_ip_forwarding          = true
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "host1_ni_config"
    subnet_id                     = "${azurerm_subnet.kafkars.id}"
    private_ip_address_allocation = "dynamic"
    primary                       = true
    public_ip_address_id          = "${azurerm_public_ip.host1.id}"
  }
}

resource "azurerm_managed_disk" "host1_mongo_disk" {
  name                 = "host1_mongo_disk"
  location             = "${var.location}"
  resource_group_name  = "${var.resource_group_name}"
  storage_account_type = "${var.mongo_volume_type}"
  create_option        = "Empty"
  disk_size_gb         = "${var.mongo_volume_size}"
}

resource "azurerm_virtual_machine" "host1_vm" {
  name                             = "host1"
  location                         = "${var.location}"
  resource_group_name              = "${var.resource_group_name}"
  network_interface_ids            = ["${azurerm_network_interface.host1_ni.id}"]
  vm_size                          = "Standard_D4s_v3"
  delete_os_disk_on_termination    = false
  delete_data_disks_on_termination = false

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "host1_OSDisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.host1_mongo_disk.name}"
    managed_disk_id = "${azurerm_managed_disk.host1_mongo_disk.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.host1_mongo_disk.disk_size_gb}"
  }

  os_profile {
    computer_name  = "host1"
    admin_username = "${var.username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = "${file("${var.public_key_path}")}"
    }
  }

  lifecycle {
    ignore_changes = "*"
  }
}
