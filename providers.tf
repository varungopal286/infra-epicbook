# ============================================================
# providers.tf — EpicBook Capstone
# Terraform version and Azure provider configuration
# Subscription: 01d97f29-a593-437a-afad-7bef5a9d03f3
# Region: Canada Central
# ============================================================

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  # Remote state stored in Azure Blob Storage
  # Storage account created in Step 01 of the setup guide
  backend "azurerm" {
    resource_group_name  = "azure-devops"
    storage_account_name = "epicbooktfstatevg"
    container_name       = "tfstate"
    key                  = "epicbook.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}
