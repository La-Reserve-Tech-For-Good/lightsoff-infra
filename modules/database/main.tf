locals {
  allocated_storage     = 10
  max_allocated_storage = local.allocated_storage * 2
  name                  = "lightsoff"
  environment           = terraform.workspace
}

resource "aws_security_group" "database_sg" {
  name        = "allow_database_access-${local.environment}"
  description = "Allow database inbound traffic"
}

resource "aws_apigatewayv2_vpc_link" "database" {
  name               = "${local.name}-${local.environment}"
  security_group_ids = [aws_security_group.database_sg.id]
  subnet_ids = [
    var.subnet_a_id,
    # This one is not working for some reason..
    # var.subnet_b_id,
    var.subnet_c_id
  ]
}

resource "aws_db_instance" "lightsoff" {
  identifier              = "${local.name}-${local.environment}"
  allocated_storage       = local.allocated_storage
  max_allocated_storage   = local.max_allocated_storage
  backup_retention_period = 7

  instance_class              = "db.t3.micro"
  engine                      = "postgres"
  engine_version              = "14.4"
  port                        = var.database_port
  auto_minor_version_upgrade  = false
  allow_major_version_upgrade = false

  db_name  = local.name
  username = var.database_username
  password = var.database_password

  skip_final_snapshot = true
  maintenance_window  = "Sat:02:00-Sat:05:00"

  apply_immediately = true

  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.database_sg.id]
}
