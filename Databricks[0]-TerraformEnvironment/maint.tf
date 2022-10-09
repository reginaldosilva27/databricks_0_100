#Define random
resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

#Define locals
locals {
  prefix = "databricksdemo${random_string.naming.result}"
  tags = {
    Environment = "Analytcs"
    Owner       = lookup(data.external.me.result, "name")
    Project = "DemosReginaldo"
  }
}

#Step 0
#Create Resource Group
resource "azurerm_resource_group" "rg_databricks" {
  name     = "${local.prefix}-rg"
  location = var.region
  tags     = local.tags
}

#Intance az client configs, get infos from az cli
data "azurerm_client_config" "client_config" {}

#Step 1
#Create a App Registration to Databricks cluster
resource "azuread_application" "app_storage_databricks" {
  display_name = "app_storage_databricks"
  owners       = [data.azurerm_client_config.client_config.object_id]
}

#Step 1
#Create a Secret for App Registration
resource "azuread_application_password" "app_storage_databricks_secret" {
  application_object_id = azuread_application.app_storage_databricks.object_id
}

#Step 1
#Create a ServicePrincipal
resource "azuread_service_principal" "service_principal_databricks" {
  application_id               = azuread_application.app_storage_databricks.application_id
  app_role_assignment_required = false
}

#Step 2
#Create a Storage Account for blobs with Hierarchy namespace
resource "azurerm_storage_account" "sadatalake" {
  name                     = var.storage_datalake
  resource_group_name      = azurerm_resource_group.rg_databricks.name
  location                 = azurerm_resource_group.rg_databricks.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true
  tags = {
    environment = "Analytcs"
  }
}

#Step 3
#Create a container sadatalake using azurerm_storage_data_lake_gen2_filesystem
resource "azurerm_storage_data_lake_gen2_filesystem" "containerlanding" {
  name               = "landingc"
  storage_account_id = azurerm_storage_account.sadatalake.id

  ace {
    type = "user"
    id = "c36f3f7d-1229-479c-a215-f2c60daa7ca8"
    permissions  = "rwx"
  }
  ace {
    type = "user"
    scope = "default"
    id = "c36f3f7d-1229-479c-a215-f2c60daa7ca8"
    permissions  = "rwx"
  }
}

#Step 3
#Create a Container called Bronze using azurerm_storage_container
resource "azurerm_storage_container" "containerbronze" {
  name                  = "bronze"
  storage_account_name  = azurerm_storage_account.sadatalake.name
  container_access_type = "private"
}

#Step 3
#Create a Container called Silver
resource "azurerm_storage_container" "containersilver" {
  name                  = "silver"
  storage_account_name  = azurerm_storage_account.sadatalake.name
  container_access_type = "private"
}

#Step 3
#Create a Container called Gold
resource "azurerm_storage_container" "containergold" {
  name                  = "gold"
  storage_account_name  = azurerm_storage_account.sadatalake.name
  container_access_type = "private"
}

#Step 3
# assign reader role for team working on subscription sub-dev
resource "azurerm_role_assignment" "app_databricks_contributor_role" {
  scope                = azurerm_storage_account.sadatalake.id
  role_definition_name = "Contributor"
  principal_id       = azuread_service_principal.service_principal_databricks.id
}

#Step 4
#Create a Keyvault with policies
resource "azurerm_key_vault" "azkeyvault" {
  name                       = "azkeyvault${random_string.naming.result}"
  location                   = azurerm_resource_group.rg_databricks.location
  resource_group_name        = azurerm_resource_group.rg_databricks.name
  tenant_id                  = data.azurerm_client_config.client_config.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.client_config.tenant_id
    object_id = data.azurerm_client_config.client_config.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List"
    ]
  }
  access_policy {
    tenant_id = data.azurerm_client_config.client_config.tenant_id
    object_id = azuread_application.app_storage_databricks.application_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List"
    ]
  }
}

#Step 4
#Create a secret
resource "azurerm_key_vault_secret" "secretappstoragedatabricks" {
  name         = "secret-app-storage-databricks"
  value        = azuread_application_password.app_storage_databricks_secret.value
  key_vault_id = azurerm_key_vault.azkeyvault.id
}

#Step 5
#Create a Databricks Premium Workspace
resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                        = "${local.prefix}-workspace"
  resource_group_name         = azurerm_resource_group.rg_databricks.name
  location                    = azurerm_resource_group.rg_databricks.location
  sku                         = "premium"
  managed_resource_group_name = "${local.prefix}-workspace-rg"
  tags                        = local.tags
}

#Limitation: https://github.com/databricks/databricks-cli/issues/338
#Create Databricks Secret Scope With Azure keyvault
#resource "databricks_secret_scope" "secretscope" {
#  name = "terraform-demo-scope"
#
#    keyvault_metadata {
#    resource_id = azurerm_key_vault.azkeyvault.id
#    dns_name    = azurerm_key_vault.azkeyvault.vault_uri
#  }
#}

#Step 6
#Create a Databricks Cluster using App Registration to connect Storage
resource "databricks_cluster" "dtb_cluster" {
  cluster_name            = var.cluster_dev_name
  spark_version           = var.databricks_spark_version
  node_type_id            = var.databricks_node_type
  autotermination_minutes = 20
  data_security_mode = "LEGACY_PASSTHROUGH"
  autoscale {
    min_workers = 1
    max_workers = 2
  }
  #Limitation: https://github.com/databricks/databricks-cli/issues/338
  #spark_conf = {
  #  "fs.azure.account.oauth2.client.secret" : "{{secrets/${databricks_secret_scope.secretscope}/${azurerm_key_vault_secret.secretappstoragedatabricks.name}}}",
  #  "fs.azure.account.oauth2.client.endpoint" : "https://login.microsoftonline.com/${data.azurerm_client_config.client_config.tenant_id}/oauth2/token",
  #  "fs.azure.account.oauth2.client.id" :  "429ef5a2-0c9d-4cd7-b888-55b7bf9772c1",
  #  "fs.azure.account.oauth.provider.type" : "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
  #  "fs.azure.account.auth.type" : "OAuth"
  #}
}

#Step 7
#Create a sample notebook
resource "databricks_notebook" "notebook_demo" {
  path     = "/demo/Terraform"
  language = "PYTHON"
  content_base64 = base64encode(<<-EOT
    # created from ${abspath(path.module)}
    display(spark.range(10))
    # COMMAND ----------
    dbutils.fs.ls('abfss://landingc@sadatalakedemoterraform.dfs.core.windows.net/raw_data/')
    # COMMAND ----------
    spark.read.csv('abfss://landingc@sadatalakedemoterraform.dfs.core.windows.net/rawdata/*').display()
    EOT
  )
}

#Step 7
#Import notebooks from local folder
resource "databricks_notebook" "notebook_labs" {
  source = var.notebooks_source_path
  path   = var.notebooks_target_path
}


#Step 8
resource "azurerm_storage_blob" "uploadcsv" {
  name                   = "addresses.csv"
  storage_account_name   = azurerm_storage_account.sadatalake.name
  storage_container_name = azurerm_storage_data_lake_gen2_filesystem.containerlanding.name
  type                   = "Block"
  source                 = "addresses.csv"
}

#Step 8
resource "azurerm_storage_blob" "uploadcsv2" {
  name                   = "/raw_data/addresses2.csv"
  storage_account_name   = azurerm_storage_account.sadatalake.name
  storage_container_name = azurerm_storage_data_lake_gen2_filesystem.containerlanding.name
  type                   = "Block"
  source                 = "addresses.csv"
}