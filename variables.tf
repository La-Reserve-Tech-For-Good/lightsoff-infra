variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "database_username" {
  type      = string
  sensitive = true
}

variable "database_password" {
  type      = string
  sensitive = true
}
