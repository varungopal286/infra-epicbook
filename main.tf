# ============================================================
# main.tf — EpicBook Capstone (Single VM Architecture)
#
# Subscription: 01d97f29-a593-437a-afad-7bef5a9d03f3
# Region: Canada Central
#
# Single VM runs: Nginx (port 80) + Node.js (port 8080) + MySQL
# Nginx proxies port 80 → localhost:8080 on the same machine
# This fits within the 4 vCPU free tier quota:
#   Agent VM (2 vCPU) + EpicBook VM (2 vCPU) = 4 vCPU
# ============================================================

# ============================================================
# Resource Group
# ============================================================
resource "azurerm_resource_group" "epicbook_rg" {
  name     = var.resource_group
  location = var.location

  tags = {
    project     = "epicbook"
    environment = "dev"
    managed_by  = "terraform"
  }
}

# ============================================================
# Virtual Network
# ============================================================
resource "azurerm_virtual_network" "vnet" {
  name                = "epicbook-vnet"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.epicbook_rg.location
  resource_group_name = azurerm_resource_group.epicbook_rg.name

  tags = { project = "epicbook" }
}

# ============================================================
# Subnet
# ============================================================
resource "azurerm_subnet" "subnet" {
  name                 = "epicbook-subnet"
  resource_group_name  = azurerm_resource_group.epicbook_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefix]
}

# ============================================================
# Network Security Group
# Allows: SSH (22), HTTP (80), Node.js App (8080), MySQL (3306)
# ============================================================
resource "azurerm_network_security_group" "nsg" {
  name                = "epicbook-nsg"
  location            = azurerm_resource_group.epicbook_rg.location
  resource_group_name = azurerm_resource_group.epicbook_rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-App"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-MySQL"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = { project = "epicbook" }
}

# ============================================================
# NSG — Associate with Subnet
# ============================================================
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ============================================================
# Public IP
# ============================================================
resource "azurerm_public_ip" "pip" {
  name                = "epicbook-pip"
  location            = azurerm_resource_group.epicbook_rg.location
  resource_group_name = azurerm_resource_group.epicbook_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = { project = "epicbook" }
}

# ============================================================
# Network Interface
# ============================================================
resource "azurerm_network_interface" "nic" {
  name                = "epicbook-nic"
  location            = azurerm_resource_group.epicbook_rg.location
  resource_group_name = azurerm_resource_group.epicbook_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }

  tags = { project = "epicbook" }
}

# ============================================================
# Linux Virtual Machine — EpicBook (Single VM)
# Runs: Nginx + Node.js + MySQL
# Ubuntu 22.04 LTS Gen2 — same image as previous projects
# ============================================================
resource "azurerm_linux_virtual_machine" "epicbook_vm" {
  name                = "epicbook-vm"
  resource_group_name = azurerm_resource_group.epicbook_rg.name
  location            = azurerm_resource_group.epicbook_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  disable_password_authentication = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    project     = "epicbook"
    role        = "all-in-one"
    environment = "dev"
    managed_by  = "terraform"
  }
}
