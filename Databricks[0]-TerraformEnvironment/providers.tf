terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.0"
    }
    random  = "~> 2.2"
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
        prevent_deletion_if_contains_resources = false
      }
  }
}

provider "databricks" {
    azure_workspace_resource_id = azurerm_databricks_workspace.databricks_workspace.id
    azure_use_msi = true
}
