provider "aws" {
  region = var.aws_region
}

module "common" {
  source = "./modules/common"
}

module "database" {
  source = "./modules/database"

  default_security_group_id = module.common.default_security_group_id
  database_username         = var.database_username
  database_password         = var.database_password
}
