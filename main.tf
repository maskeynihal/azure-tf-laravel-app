terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "getdemo-website-resource" {
  name     = "getdemo-website-resource"
  location = "East Asia"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "getdemo-website-virtual-network" {
  name                = "getdemo-website-virtual-network"
  resource_group_name = azurerm_resource_group.getdemo-website-resource.name
  location            = azurerm_resource_group.getdemo-website-resource.location
  address_space       = ["10.123.0.0/16"]

  tags = {
    "environment" = "dev"
  }
}

resource "azurerm_subnet" "getdemo-website-subnet" {
  name                 = "getdemo-website-subnet-1"
  resource_group_name  = azurerm_resource_group.getdemo-website-resource.name
  virtual_network_name = azurerm_virtual_network.getdemo-website-virtual-network.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "getdemo-website-network-security-group" {
  name                = "getdemo-website-network-security-group"
  location            = azurerm_resource_group.getdemo-website-resource.location
  resource_group_name = azurerm_resource_group.getdemo-website-resource.name

  tags = {
    "environment" = "dev"
  }
}

resource "azurerm_network_security_rule" "getdemo-website-network-security-rule" {
  name                        = "getdemo-website-network-security-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.getdemo-website-resource.name
  network_security_group_name = azurerm_network_security_group.getdemo-website-network-security-group.name
}

resource "azurerm_subnet_network_security_group_association" "getdemo-website-security-association" {
  subnet_id                 = azurerm_subnet.getdemo-website-subnet.id
  network_security_group_id = azurerm_network_security_group.getdemo-website-network-security-group.id
}

resource "azurerm_public_ip" "getdemo-website-public-ip" {
  name                    = "getdemo-website-public-ip"
  location                = azurerm_resource_group.getdemo-website-resource.location
  resource_group_name     = azurerm_resource_group.getdemo-website-resource.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "getdemo-website-network-interface" {
  name                = "getdemo-website-network-interface"
  location            = azurerm_resource_group.getdemo-website-resource.location
  resource_group_name = azurerm_resource_group.getdemo-website-resource.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.getdemo-website-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.getdemo-website-public-ip.id
  }

  tags = {
    "environment" = "dev"
  }
}

resource "azurerm_linux_virtual_machine" "getdemo-website-virtual-machine" {
  name                = "getdemo-website-virtual-machine"
  location            = azurerm_resource_group.getdemo-website-resource.location
  resource_group_name = azurerm_resource_group.getdemo-website-resource.name
  size                = var.virtual_machine_size
  admin_username      = var.virtual_machine_user
  network_interface_ids = [
    azurerm_network_interface.getdemo-website-network-interface.id,
  ]

  admin_ssh_key {
    username   = var.virtual_machine_user
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  provisioner "remote-exec" {
    script = "initialize.bash"
    connection {
      host        = self.public_ip_address
      user        = "azureuser"
      type        = "ssh"
      private_key = file("~/.ssh/id_rsa")
    }
  }
}
