variable "region" {
  type    = string
  default = "eastus"
}

variable "databricks_node_type" {
  type    = string
  default = "Standard_D3_v2"
}

variable "databricks_spark_version" {
  type    = string
  default = "10.4.x-scala2.12"
}

variable "notebooks_source_path" {
  type    = string
  default = "/Users/reginaldo.silva/Documents/Databricks/Notebooks/Demos/Lab.dbc"
}

variable "notebooks_target_path" {
  type    = string
  default = "/Terraform/Lab"
}

variable "cluster_dev_name" {
  type    = string
  default = "reginaldo_cluster_demo"
}

variable "storage_datalake" {
  type    = string
  default = "sadatalakedemoterraform"
}

