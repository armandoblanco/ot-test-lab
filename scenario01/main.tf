provider "azurerm" {
  features {}
}

# Resource Group for Control Plane
resource "azurerm_resource_group" "controlplane" {
  name     = var.rg_controlplane_name
  location = var.location
}

# Resource Group for SCE01
resource "azurerm_resource_group" "sce01" {
  name     = var.rg_sce01_name
  location = var.location
}

# VNET Control Plane
resource "azurerm_virtual_network" "controlplane" {
  name                = var.vnet_controlplane_name
  address_space       = var.vnet_controlplane_address_space
  location            = azurerm_resource_group.controlplane.location
  resource_group_name = azurerm_resource_group.controlplane.name
}

# Subnet in VNET Control Plane
resource "azurerm_subnet" "controlplane_subnet" {
  name                 = "controlplane-subnet"
  resource_group_name  = azurerm_resource_group.controlplane.name
  virtual_network_name = azurerm_virtual_network.controlplane.name
  address_prefixes     = ["172.16.0.0/24"]
}

# VNET DMZ LAN
resource "azurerm_virtual_network" "dmzlan" {
  name                = var.vnet_dmzlan_name
  address_space       = var.vnet_dmzlan_address_space
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name
}

# Subnets in VNET DMZ LAN
resource "azurerm_subnet" "AzureBastionSubnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.sce01.name
  virtual_network_name = azurerm_virtual_network.dmzlan.name
  address_prefixes     = ["10.0.3.0/26"]  # 64 addresses
}

resource "azurerm_subnet" "dmzlan_firewall" {
  name                 = "azurefirewall"
  resource_group_name  = azurerm_resource_group.sce01.name
  virtual_network_name = azurerm_virtual_network.dmzlan.name
  address_prefixes     = ["10.0.3.64/26"]
}

resource "azurerm_subnet" "dmzlan_vmlayer3" {
  name                 = "vm-layer3"
  resource_group_name  = azurerm_resource_group.sce01.name
  virtual_network_name = azurerm_virtual_network.dmzlan.name
  address_prefixes     = ["10.0.3.128/25"]
}

# VNET Layer 2
resource "azurerm_virtual_network" "layer2" {
  name                = var.vnet_layer2_name
  address_space       = var.vnet_layer2_address_space
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name
}

# Subnet in VNET Layer 2
resource "azurerm_subnet" "layer2_subnet" {
  name                 = "layer2-subnet"
  resource_group_name  = azurerm_resource_group.sce01.name
  virtual_network_name = azurerm_virtual_network.layer2.name
  address_prefixes     = ["10.0.2.0/24"]
}

# NSG for Bastion
resource "azurerm_network_security_group" "nsg_bastion" {
  name                = "NSG-Bastion"
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name
}

# NSG for DMZ LAN
resource "azurerm_network_security_group" "nsg_dmzlan" {
  name                = "NSG-dmzlan"
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name
}

# NSG for Layer 2
resource "azurerm_network_security_group" "nsg_layer2" {
  name                = "NSG-layer2"
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name
}

# Azure Firewall
resource "azurerm_firewall" "azfw-l01" {
  name                = "azfw-l01"
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name
  sku_name            = "AZFW_Hub"
  sku_tier            = "Standard"
}

# Route Table for Control Plane
resource "azurerm_route_table" "controlplane" {
  name                = "routetable-controlplane"
  location            = azurerm_resource_group.controlplane.location
  resource_group_name = azurerm_resource_group.controlplane.name
}

# Route Table for DMZ LAN
resource "azurerm_route_table" "dmzlan" {
  name                = "routetable-dmzlan"
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name
}

# Route Table for Layer 2
resource "azurerm_route_table" "layer2" {
  name                = "routetable-layer2"
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name
}

# Virtual Network Peering
resource "azurerm_virtual_network_peering" "controlplane_to_dmzlan" {
  name                      = "peer-controlplane-to-dmzlan"
  resource_group_name       = azurerm_resource_group.controlplane.name
  virtual_network_name      = azurerm_virtual_network.controlplane.name
  remote_virtual_network_id = azurerm_virtual_network.dmzlan.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# VMs in DMZ LAN
locals {
  ubuntu_vms = [
    { name = "SCE01VM01", ip_configuration_name = "ipconfig1" },
    { name = "SCE01VM02", ip_configuration_name = "ipconfig2" }
    #,
    #{ name = "SCE01VM03", ip_configuration_name = "ipconfig3" },
    #{ name = "SCE01VM04", ip_configuration_name = "ipconfig4" },
    #{ name = "SCE01VM05", ip_configuration_name = "ipconfig5" },
    #{ name = "SCE01VM06", ip_configuration_name = "ipconfig6" }
  ]
}

resource "azurerm_network_interface" "dmzlan_nics" {
  count               = length(local.ubuntu_vms)
  name                = "nic-${local.ubuntu_vms[count.index].name}"
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name

  ip_configuration {
    name                          = local.ubuntu_vms[count.index].ip_configuration_name
    subnet_id                     = azurerm_subnet.dmzlan_vmlayer3.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "dmzlan_ubuntu_vms" {
  count                = length(local.ubuntu_vms)
  name                 = local.ubuntu_vms[count.index].name
  location             = azurerm_resource_group.sce01.location
  resource_group_name  = azurerm_resource_group.sce01.name
  network_interface_ids = [element(azurerm_network_interface.dmzlan_nics[*].id, count.index)]
  vm_size              = var.ubuntu_vm_size

  storage_os_disk {
    name              = "osdisk-${local.ubuntu_vms[count.index].name}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_profile {
    computer_name  = local.ubuntu_vms[count.index].name
    admin_username = var.vm_admin_username
    admin_password = var.vm_admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

# Windows VMs in Layer 2
locals {
  windows_vms = [
    { name = "SCE01VM07", ip_configuration_name = "ipconfig7" },
    { name = "SCE01VM08", ip_configuration_name = "ipconfig8" }
  ]
}

resource "azurerm_network_interface" "layer2_nics" {
  count               = length(local.windows_vms)
  name                = "nic-${local.windows_vms[count.index].name}"
  location            = azurerm_resource_group.sce01.location
  resource_group_name = azurerm_resource_group.sce01.name

  ip_configuration {
    name                          = local.windows_vms[count.index].ip_configuration_name
    subnet_id                     = azurerm_subnet.layer2_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
