provider "aws" {
  region = var.aws_region
}

module "database" {
  source = "./modules/database"

  database_username = var.database_username
  database_password = var.database_password
}
