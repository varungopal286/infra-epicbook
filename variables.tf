# ============================================================
# variables.tf — EpicBook Capstone
# ============================================================

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "resource_group" {
  description = "Resource group name for EpicBook resources"
  type        = string
  default     = "epicbook-rg"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "canadacentral"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.3.0.0/16"
}

variable "subnet_prefix" {
  description = "Address prefix for the subnet"
  type        = string
  default     = "10.3.1.0/24"
}

variable "vm_size" {
  description = "Azure VM size for the EpicBook VM"
  type        = string
  default     = "Standard_B2s_v2"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key content for VM access"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "MySQL root password for the database"
  type        = string
  sensitive   = true
}
