provider "aws" {
  region = var.aws_region
}

module "common" {
  source = "./modules/common"
}

module "database" {
  source = "./modules/database"

  default_vpc_id    = module.common.default_vpc_id
  subnet_a_id       = module.common.default_subnet_a_id
  subnet_b_id       = module.common.default_subnet_b_id
  subnet_c_id       = module.common.default_subnet_c_id
  database_username = var.database_username
  database_password = var.database_password
}

module "api" {
  source = "./modules/api"

  database_sg_id = module.database.database_sg_id
}


module "metabase" {
  count  = terraform.workspace == "production" ? 1 : 0
  source = "./modules/metabase"

  aws_region               = var.aws_region
  default_vpc_id           = module.common.default_vpc_id
  subnet_a_id              = module.common.default_subnet_a_id
  subnet_b_id              = module.common.default_subnet_b_id
  subnet_c_id              = module.common.default_subnet_c_id
  database_username        = var.metabase_database_username
  database_password        = var.metabase_database_password
  encryption_key           = var.metabase_encryption_key
  lightsoff_database_sg_id = module.database.database_sg_id
}
