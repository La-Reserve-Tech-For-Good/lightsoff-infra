variable "aws_region" {
  type    = string
  default = "eu-west-3"
}

variable "default_vpc_id" {
  type = string
}

variable "subnet_a_id" {
  type = string
}

variable "subnet_b_id" {
  type = string
}

variable "subnet_c_id" {
  type = string
}

variable "database_username" {
  type      = string
  sensitive = true
}

variable "database_password" {
  type      = string
  sensitive = true
}

variable "encryption_key" {
  type      = string
  sensitive = true
}

variable "lightsoff_database_sg_id" {
  type = string
}

variable "lightsoff_database_port" {
  type    = number
  default = 5432
}
