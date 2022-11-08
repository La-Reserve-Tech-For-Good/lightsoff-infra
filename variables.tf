variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

# database module
variable "database_username" {
  type      = string
  sensitive = true
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "database_port" {
  type    = number
  default = 5432
}

# metabase_module
variable "metabase_database_username" {
  type      = string
  sensitive = true
}

variable "metabase_database_password" {
  type      = string
  sensitive = true
}

variable "metabase_encryption_key" {
  type      = string
  sensitive = true
}
