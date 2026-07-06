# vm.tf — Red y máquina virtual Linux

# Red virtual: espacio de direcciones privado donde vive la VM
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefijo}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.etiquetas
}

# Subred dentro de la red virtual
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefijo}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# IP pública: para acceder a la VM desde Internet
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefijo}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.etiquetas
}

# NSG (firewall): abre SOLO los puertos necesarios (22 SSH y 443 HTTPS)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefijo}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.etiquetas

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Tarjeta de red (NIC): conecta la VM a la subred y le asigna la IP pública
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefijo}-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.etiquetas

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

# Asociar el NSG (firewall) a la tarjeta de red
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# La máquina virtual Linux (Ubuntu 22.04 LTS)
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.prefijo}-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_tamano
  admin_username        = var.vm_usuario
  network_interface_ids = [azurerm_network_interface.nic.id]

  # Solo acceso por clave SSH (sin contraseña)
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_usuario
    public_key = file(pathexpand(var.ssh_clave_publica_path))
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = var.etiquetas
}