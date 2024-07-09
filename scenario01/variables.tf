variable "location" {
  description = "Azure location for resources"
  default     = "East US 2"
}

variable "rg_controlplane_name" {
  description = "Resource group for Control Plane"
  default     = "LAB-Control-Plane-SCE01"
}

variable "rg_sce01_name" {
  description = "Resource group for SCE01"
  default     = "LAB-SCE01-Location01"
}

variable "vnet_controlplane_name" {
  description = "Virtual network for Control Plane"
  default     = "ControlPlane"
}

variable "vnet_controlplane_address_space" {
  description = "Address space for the Control Plane VNET"
  default     = ["172.16.0.0/24"]
}

variable "vnet_dmzlan_name" {
  description = "Virtual network for DMZ LAN"
  default     = "dmzvlan"
}

variable "vnet_dmzlan_address_space" {
  description = "Address space for the DMZ LAN VNET"
  default     = ["10.0.3.0/24"]
}

variable "vnet_layer2_name" {
  description = "Virtual network for Layer 2"
  default     = "layer2"
}

variable "vnet_layer2_address_space" {
  description = "Address space for the Layer 2 VNET"
  default     = ["10.0.2.0/24"]
}

variable "vm_admin_username" {
  description = "Admin username for the virtual machines"
  default     = "adminuser"
}

variable "vm_admin_password" {
  description = "Admin password for the virtual machines"
  default     = "Password1234!"
}

variable "ubuntu_vm_size" {
  description = "Size of the Ubuntu virtual machines"
  default     = "Standard_D2_v5"
}

variable "windows_vm_size" {
  description = "Size of the Windows virtual machines"
  default     = "Standard_D2_v5"
}

variable "dmzlan_bastion_subnet_prefix" {
  description = "Subnet prefix for Bastion in DMZ LAN VNET"
  default     = "10.0.3.0/26"
}

variable "dmzlan_firewall_subnet_prefix" {
  description = "Subnet prefix for Azure Firewall in DMZ LAN VNET"
  default     = "10.0.3.64/26"
}
