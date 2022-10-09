output "workspaceUser_result" {
  value = data.external.me.result
}

output "databricks_host" {
  value = "https://${azurerm_databricks_workspace.databricks_workspace.workspace_url}/"
}

output "output_app_storage_databricks_secret" {
  value = azuread_application_password.app_storage_databricks_secret.key_id
}