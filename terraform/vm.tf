# vm.tf — Red y máquina virtual Linux

# Red virtual: espacio de direcciones privado donde vive la VM
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefijo}-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"] # Rango privado (65000 direcciones)
  tags                = var.etiquetas
}

# Subred: Subdivisión de la red virtual donde se conecta la VM
resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefijo}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name # A qué red virtual pertenece
  address_prefixes     = ["10.0.1.0/24"] # Subconjunto del /16 (256 direcciones)
}

# IP pública: Dirección visible desde Internet para alcanzar la VM
resource "azurerm_public_ip" "pip" {
  name                = "${var.prefijo}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static" # IP fija (no cambia al reiniciar/apagar la VM)
  sku                 = "Standard" # Nivel requerido para IP estática; cerrado por defecto
  tags                = var.etiquetas
}

# NSG (firewall): abre SOLO los puertos necesarios (22 SSH y 443 HTTPS)
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefijo}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = var.etiquetas

  # Regla 1: Permite SSH (puerto 22) para que Ansible administre la VM
  security_rule {
    name                       = "SSH"
    priority                   = 1001       # Menor número = mayor prioridad
    direction                  = "Inbound"  # Tráfico entrante
    access                     = "Allow"    # Permitir
    protocol                   = "Tcp"
    source_port_range          = "*"        # Cualquier puerto de origen
    destination_port_range     = "22"       # Puerto SSH
    source_address_prefix      = "*"        # Desde cualquier IP (se podría restringir a la propia)
    destination_address_prefix = "*"
  }

  # Regla 2: Permite HTTPS (puerto 443) para servir la web
  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"      # Puerto HTTPS
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
    subnet_id                     = azurerm_subnet.subnet.id # En qué subred se conecta
    private_ip_address_allocation = "Dynamic"                # IP privada asignada
    public_ip_address_id          = azurerm_public_ip.pip.id # Le pega la IP pública
  }
}

# Asociar el NSG (firewall) a la NIC: aplica sus reglas al tráfico de la VM
resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# La máquina virtual Linux (Ubuntu 22.04 LTS)
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "${var.prefijo}-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = var.vm_tamano                       # hardware: CPU/RAM (B2ats_v2 = 2 vCPU)
  admin_username        = var.vm_usuario                      # Usuario administrador
  network_interface_ids = [azurerm_network_interface.nic.id]  # Tarjetas(s) de red de la VM

  # Solo acceso por clave SSH (sin contraseña)
  disable_password_authentication = true

  # Registra la clave SSH pública en la VM para el usuario administrador
  admin_ssh_key {
    username   = var.vm_usuario
    public_key = file(pathexpand(var.ssh_clave_publica_path)) # file() lee el contenido del fichero; pathexpand() convierte el '~' en la ruta real
  }

  # Disco del sistema operativo
  os_disk {
    caching              = "ReadWrite"      # Modo de caché del disco de SO
    storage_account_type = "Standard_LRS"   # Disco estándar (HDD), el más económico
  }

  # Imagen de sistema operativo del Marketplace de Azure (Ubuntu 22.04 LTS Gen2)
  source_image_reference {
    publisher = "Canonical"                     # Editor de la imagen (empresa de Ubuntu)
    offer     = "0001-com-ubuntu-server-jammy"  # Producto (Ubuntu Server "Jammy" = 22.04)
    sku       = "22_04-lts-gen2"                # Variante (22.04 LTS, Generación 2)
    version   = "latest"                        # Última compilación disponible
  }

  tags = var.etiquetas
}