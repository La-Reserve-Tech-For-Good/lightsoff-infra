locals {
  allocated_storage = 10
  name              = "metabase"
  environment       = terraform.workspace
  database_port     = 5432
  web_app_port      = 3000
}
