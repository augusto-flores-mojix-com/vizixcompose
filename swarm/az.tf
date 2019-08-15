terraform {
  backend "s3" {
    bucket = "vizix-terraform-state"
    key    = "kohls_vizix"
  }
}

resource "azurerm_resource_group" "kohls" {
  name     = "kohls_vizix"
  location = "West US 2"
}

resource "azurerm_virtual_network" "kohls" {
  name                = "${azurerm_resource_group.kohls.name}-virtnet"
  address_space       = ["10.100.0.0/16"]
  location            = "${azurerm_resource_group.kohls.location}"
  resource_group_name = "${azurerm_resource_group.kohls.name}"
}

resource "azurerm_subnet" "kohls" {
  name                 = "${azurerm_resource_group.kohls.name}-subnet"
  resource_group_name  = "${azurerm_resource_group.kohls.name}"
  virtual_network_name = "${azurerm_virtual_network.kohls.name}"
  address_prefix       = "10.100.2.0/24"
}

resource "azurerm_network_security_group" "kohls" {
  name                = "${azurerm_resource_group.kohls.name}-sg"
  location            = "${azurerm_resource_group.kohls.location}"
  resource_group_name = "${azurerm_resource_group.kohls.name}"
}

resource "azurerm_network_security_rule" "kohls" {
  name                        = "ssh"
  priority                    = 4095
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.kohls.name}"
  network_security_group_name = "${azurerm_network_security_group.kohls.name}"
}

resource "azurerm_network_security_rule" "grafana" {
  name                        = "grafana"
  priority                    = 4035
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.kohls.name}"
  network_security_group_name = "${azurerm_network_security_group.kohls.name}"
}

resource "azurerm_network_security_rule" "http" {
  name                        = "http"
  priority                    = 4094
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8001"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.kohls.name}"
  network_security_group_name = "${azurerm_network_security_group.kohls.name}"
}

resource "azurerm_network_security_rule" "ui" {
  name                        = "ui"
  priority                    = 4093
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.kohls.name}"
  network_security_group_name = "${azurerm_network_security_group.kohls.name}"
}

resource "azurerm_network_security_rule" "services" {
  name                        = "services"
  priority                    = 4092
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.kohls.name}"
  network_security_group_name = "${azurerm_network_security_group.kohls.name}"
}

resource "azurerm_network_security_rule" "logsdownloader" {
  name                        = "logsdownloader"
  priority                    = 4012
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8000"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.kohls.name}"
  network_security_group_name = "${azurerm_network_security_group.kohls.name}"
}

resource "azurerm_network_security_rule" "prometheus" {
  name                        = "prometheus"
  priority                    = 4068
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9009"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.kohls.name}"
  network_security_group_name = "${azurerm_network_security_group.kohls.name}"
}

resource "azurerm_network_security_rule" "httpbridge" {
  name                        = "httpbridge"
  priority                    = 4088
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9090"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.kohls.name}"
  network_security_group_name = "${azurerm_network_security_group.kohls.name}"
}

###### Database Server ######
resource "azurerm_public_ip" "database" {
  name                         = "database-ip"
  location                     = "${azurerm_resource_group.kohls.location}"
  resource_group_name          = "${azurerm_resource_group.kohls.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "database" {
  name                      = "database-ni"
  location                  = "${azurerm_resource_group.kohls.location}"
  resource_group_name       = "${azurerm_resource_group.kohls.name}"
  network_security_group_id = "${azurerm_network_security_group.kohls.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.kohls.id}"
    private_ip_address_allocation = "dynamic"
    primary                       = true
    public_ip_address_id          = "${azurerm_public_ip.database.id}"
  }
}

resource "azurerm_managed_disk" "database" {
  name                 = "database-data"
  location             = "${azurerm_resource_group.kohls.location}"
  resource_group_name  = "${azurerm_resource_group.kohls.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "database" {
  name                  = "database"
  location              = "${azurerm_resource_group.kohls.location}"
  resource_group_name   = "${azurerm_resource_group.kohls.name}"
  network_interface_ids = ["${azurerm_network_interface.database.id}"]
  vm_size               = "Standard_F16s_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "database-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.database.name}"
    managed_disk_id = "${azurerm_managed_disk.database.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.database.disk_size_gb}"
  }

  os_profile {
    computer_name  = "database"
    admin_username = "vizix"
    admin_password = "m0j1xInc"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

###### ViZix Server ######
resource "azurerm_public_ip" "vizix" {
  name                         = "vizix-ip"
  location                     = "${azurerm_resource_group.kohls.location}"
  resource_group_name          = "${azurerm_resource_group.kohls.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "vizix" {
  name                      = "vizix-ni"
  location                  = "${azurerm_resource_group.kohls.location}"
  resource_group_name       = "${azurerm_resource_group.kohls.name}"
  network_security_group_id = "${azurerm_network_security_group.kohls.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.kohls.id}"
    private_ip_address_allocation = "dynamic"
    primary                       = true
    public_ip_address_id          = "${azurerm_public_ip.vizix.id}"
  }
}

resource "azurerm_managed_disk" "vizix" {
  name                 = "vizix-data"
  location             = "${azurerm_resource_group.kohls.location}"
  resource_group_name  = "${azurerm_resource_group.kohls.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "256"
}

resource "azurerm_virtual_machine" "vizix" {
  name                  = "vizix"
  location              = "${azurerm_resource_group.kohls.location}"
  resource_group_name   = "${azurerm_resource_group.kohls.name}"
  network_interface_ids = ["${azurerm_network_interface.vizix.id}"]
  vm_size               = "Standard_F8s_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "vizix-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.vizix.name}"
    managed_disk_id = "${azurerm_managed_disk.vizix.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.vizix.disk_size_gb}"
  }

  os_profile {
    computer_name  = "vizix"
    admin_username = "vizix"
    admin_password = "m0j1xInc"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

###### Kafka Server ######
resource "azurerm_public_ip" "kafka" {
  name                         = "kafka-ip"
  location                     = "${azurerm_resource_group.kohls.location}"
  resource_group_name          = "${azurerm_resource_group.kohls.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "kafka" {
  name                      = "kafka-ni"
  location                  = "${azurerm_resource_group.kohls.location}"
  resource_group_name       = "${azurerm_resource_group.kohls.name}"
  network_security_group_id = "${azurerm_network_security_group.kohls.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.kohls.id}"
    private_ip_address_allocation = "dynamic"
    primary                       = true
    public_ip_address_id          = "${azurerm_public_ip.kafka.id}"
  }
}

resource "azurerm_managed_disk" "kafka" {
  name                 = "kafka-data"
  location             = "${azurerm_resource_group.kohls.location}"
  resource_group_name  = "${azurerm_resource_group.kohls.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1535"
}

resource "azurerm_virtual_machine" "kafka" {
  name                  = "kafka"
  location              = "${azurerm_resource_group.kohls.location}"
  resource_group_name   = "${azurerm_resource_group.kohls.name}"
  network_interface_ids = ["${azurerm_network_interface.kafka.id}"]
  vm_size               = "Standard_F8s_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "kafka-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.kafka.name}"
    managed_disk_id = "${azurerm_managed_disk.kafka.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.kafka.disk_size_gb}"
  }

  os_profile {
    computer_name  = "kafka"
    admin_username = "vizix"
    admin_password = "m0j1xInc"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

###### MongoInjector Server ######
resource "azurerm_public_ip" "mongoInjector" {
  name                         = "mongoInjector-ip"
  location                     = "${azurerm_resource_group.kohls.location}"
  resource_group_name          = "${azurerm_resource_group.kohls.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "mongoInjector" {
  name                      = "mongoInjector-ni"
  location                  = "${azurerm_resource_group.kohls.location}"
  resource_group_name       = "${azurerm_resource_group.kohls.name}"
  network_security_group_id = "${azurerm_network_security_group.kohls.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.kohls.id}"
    private_ip_address_allocation = "dynamic"
    primary                       = true
    public_ip_address_id          = "${azurerm_public_ip.mongoInjector.id}"
  }
}

resource "azurerm_managed_disk" "mongoInjector" {
  name                 = "mongoInjector-data"
  location             = "${azurerm_resource_group.kohls.location}"
  resource_group_name  = "${azurerm_resource_group.kohls.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1535"
}

resource "azurerm_virtual_machine" "mongoInjector" {
  name                  = "mongoInjector"
  location              = "${azurerm_resource_group.kohls.location}"
  resource_group_name   = "${azurerm_resource_group.kohls.name}"
  network_interface_ids = ["${azurerm_network_interface.mongoInjector.id}"]
  vm_size               = "Standard_F8s_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "mongoInjector-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.mongoInjector.name}"
    managed_disk_id = "${azurerm_managed_disk.mongoInjector.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.mongoInjector.disk_size_gb}"
  }

  os_profile {
    computer_name  = "mongoInjector"
    admin_username = "vizix"
    admin_password = "m0j1xInc"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

###### RulesProcessor 1 Server ######
resource "azurerm_public_ip" "rulesProcessor1" {
  name                         = "rulesProcessor1-ip"
  location                     = "${azurerm_resource_group.kohls.location}"
  resource_group_name          = "${azurerm_resource_group.kohls.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "rulesProcessor1" {
  name                      = "rulesProcessor1-ni"
  location                  = "${azurerm_resource_group.kohls.location}"
  resource_group_name       = "${azurerm_resource_group.kohls.name}"
  network_security_group_id = "${azurerm_network_security_group.kohls.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.kohls.id}"
    private_ip_address_allocation = "dynamic"
    primary                       = true
    public_ip_address_id          = "${azurerm_public_ip.rulesProcessor1.id}"
  }
}

resource "azurerm_managed_disk" "rulesProcessor1" {
  name                 = "rulesProcessor1-data"
  location             = "${azurerm_resource_group.kohls.location}"
  resource_group_name  = "${azurerm_resource_group.kohls.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1535"
}

resource "azurerm_virtual_machine" "rulesProcessor1" {
  name                  = "rulesProcessor1"
  location              = "${azurerm_resource_group.kohls.location}"
  resource_group_name   = "${azurerm_resource_group.kohls.name}"
  network_interface_ids = ["${azurerm_network_interface.rulesProcessor1.id}"]
  vm_size               = "Standard_F8s_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "rulesProcessor1-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.rulesProcessor1.name}"
    managed_disk_id = "${azurerm_managed_disk.rulesProcessor1.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.rulesProcessor1.disk_size_gb}"
  }

  os_profile {
    computer_name  = "rulesProcessor1"
    admin_username = "vizix"
    admin_password = "m0j1xInc"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

###### RulesProcessor 2 Server ######
resource "azurerm_public_ip" "rulesProcessor2" {
  name                         = "rulesProcessor2-ip"
  location                     = "${azurerm_resource_group.kohls.location}"
  resource_group_name          = "${azurerm_resource_group.kohls.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "rulesProcessor2" {
  name                      = "rulesProcessor2-ni"
  location                  = "${azurerm_resource_group.kohls.location}"
  resource_group_name       = "${azurerm_resource_group.kohls.name}"
  network_security_group_id = "${azurerm_network_security_group.kohls.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.kohls.id}"
    private_ip_address_allocation = "dynamic"
    primary                       = true
    public_ip_address_id          = "${azurerm_public_ip.rulesProcessor2.id}"
  }
}

resource "azurerm_managed_disk" "rulesProcessor2" {
  name                 = "rulesProcessor2-data"
  location             = "${azurerm_resource_group.kohls.location}"
  resource_group_name  = "${azurerm_resource_group.kohls.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1535"
}

resource "azurerm_virtual_machine" "rulesProcessor2" {
  name                  = "rulesProcessor2"
  location              = "${azurerm_resource_group.kohls.location}"
  resource_group_name   = "${azurerm_resource_group.kohls.name}"
  network_interface_ids = ["${azurerm_network_interface.rulesProcessor2.id}"]
  vm_size               = "Standard_F8s_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "rulesProcessor2-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.rulesProcessor2.name}"
    managed_disk_id = "${azurerm_managed_disk.rulesProcessor2.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.rulesProcessor2.disk_size_gb}"
  }

  os_profile {
    computer_name  = "rulesProcessor2"
    admin_username = "vizix"
    admin_password = "m0j1xInc"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

###### RulesProcessor 3 Server ######
resource "azurerm_public_ip" "rulesProcessor3" {
  name                         = "rulesProcessor3-ip"
  location                     = "${azurerm_resource_group.kohls.location}"
  resource_group_name          = "${azurerm_resource_group.kohls.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "rulesProcessor3" {
  name                      = "rulesProcessor3-ni"
  location                  = "${azurerm_resource_group.kohls.location}"
  resource_group_name       = "${azurerm_resource_group.kohls.name}"
  network_security_group_id = "${azurerm_network_security_group.kohls.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.kohls.id}"
    private_ip_address_allocation = "dynamic"
    primary                       = true
    public_ip_address_id          = "${azurerm_public_ip.rulesProcessor3.id}"
  }
}

resource "azurerm_managed_disk" "rulesProcessor3" {
  name                 = "rulesProcessor3-data"
  location             = "${azurerm_resource_group.kohls.location}"
  resource_group_name  = "${azurerm_resource_group.kohls.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1535"
}

resource "azurerm_virtual_machine" "rulesProcessor3" {
  name                  = "rulesProcessor3"
  location              = "${azurerm_resource_group.kohls.location}"
  resource_group_name   = "${azurerm_resource_group.kohls.name}"
  network_interface_ids = ["${azurerm_network_interface.rulesProcessor3.id}"]
  vm_size               = "Standard_F8s_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "rulesProcessor3-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.rulesProcessor3.name}"
    managed_disk_id = "${azurerm_managed_disk.rulesProcessor3.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.rulesProcessor3.disk_size_gb}"
  }

  os_profile {
    computer_name  = "rulesProcessor3"
    admin_username = "vizix"
    admin_password = "m0j1xInc"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

###### TransformBridge Server ######
resource "azurerm_public_ip" "transformBridge" {
  name                         = "transformBridge-ip"
  location                     = "${azurerm_resource_group.kohls.location}"
  resource_group_name          = "${azurerm_resource_group.kohls.name}"
  public_ip_address_allocation = "static"
}

resource "azurerm_network_interface" "transformBridge" {
  name                      = "transformBridge-ni"
  location                  = "${azurerm_resource_group.kohls.location}"
  resource_group_name       = "${azurerm_resource_group.kohls.name}"
  network_security_group_id = "${azurerm_network_security_group.kohls.id}"
  enable_ip_forwarding      = true

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.kohls.id}"
    private_ip_address_allocation = "dynamic"
    primary                       = true
    public_ip_address_id          = "${azurerm_public_ip.transformBridge.id}"
  }
}

resource "azurerm_managed_disk" "transformBridge" {
  name                 = "transformBridge-data"
  location             = "${azurerm_resource_group.kohls.location}"
  resource_group_name  = "${azurerm_resource_group.kohls.name}"
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

resource "azurerm_virtual_machine" "transformBridge" {
  name                  = "transformBridge"
  location              = "${azurerm_resource_group.kohls.location}"
  resource_group_name   = "${azurerm_resource_group.kohls.name}"
  network_interface_ids = ["${azurerm_network_interface.transformBridge.id}"]
  vm_size               = "Standard_F4s_v2"

  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "transformBridge-os"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_data_disk {
    name            = "${azurerm_managed_disk.transformBridge.name}"
    managed_disk_id = "${azurerm_managed_disk.transformBridge.id}"
    create_option   = "Attach"
    lun             = 1
    disk_size_gb    = "${azurerm_managed_disk.transformBridge.disk_size_gb}"
  }

  os_profile {
    computer_name  = "transformBridge"
    admin_username = "vizix"
    admin_password = "m0j1xInc"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Outputs
output "vizix_database" {
  value = "${azurerm_public_ip.database.ip_address}"
}

output "vizix_vizix_address" {
  value = "${azurerm_public_ip.vizix.ip_address}"
}

output "vizix_kafka_address" {
  value = "${azurerm_public_ip.kafka.ip_address}"
}

output "vizix_mongoInjector_address" {
  value = "${azurerm_public_ip.mongoInjector.ip_address}"
}

output "vizix_rulesProcessor1_address" {
  value = "${azurerm_public_ip.rulesProcessor1.ip_address}"
}

output "vizix_rulesProcessor2_address" {
  value = "${azurerm_public_ip.rulesProcessor2.ip_address}"
}

output "vizix_rulesProcessor3_address" {
  value = "${azurerm_public_ip.rulesProcessor3.ip_address}"
}

output "vizix_transformBridge_address" {
  value = "${azurerm_public_ip.transformBridge.ip_address}"
}
