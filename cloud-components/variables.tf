# variables.tf

variable "location" {
  description = "The location where the resources will be created."
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "The name of the existing resource group."
  default     = "RG-AEU-ECP-DEV-AIODataFusion"
}

variable "storage_account_name" {
  description = "The name of the storage account."
  type        = string
  default     = "saaeuecpdevaiodatafusion"
}

variable "storage_account_tier" {
  description = "The tier of the storage account."
  type        = string
  default     = "Standard"
}

variable "storage_account_replication_type" {
  description = "The replication type of the storage account."
  type        = string
  default     = "LRS"
}

variable "container_names" {
  description = "The names of the storage containers."
  type        = list(string)
  default     = ["bs-aeu-ecp-dev-raw", "bs-aeu-ecp-dev-structured", "bs-aeu-ecp-dev-config"]
}

variable "event_grid_namespace_name" {
  description = "The name of the Event Grid Namespace."
  type        = string
  default     = "EN-AEU-ECP-DEV-AIODATAFUSION"
}
