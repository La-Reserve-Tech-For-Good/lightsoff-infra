locals {
  allocated_storage     = 10
  max_allocated_storage = local.allocated_storage * 2
  name                  = "lightsoff"
  environment           = terraform.workspace
  database_port         = 5432
}

resource "aws_db_instance" "lightsoff" {
  identifier              = "${local.name}-${local.environment}"
  allocated_storage       = local.allocated_storage
  max_allocated_storage   = local.max_allocated_storage
  backup_retention_period = 7

  instance_class              = "db.t3.micro"
  engine                      = "postgres"
  engine_version              = "14.4"
  port                        = local.database_port
  auto_minor_version_upgrade  = false
  allow_major_version_upgrade = false

  db_name  = local.name
  username = var.database_username
  password = var.database_password

  skip_final_snapshot = true
  maintenance_window  = "Sat:02:00-Sat:05:00"

  apply_immediately = true
}

# Allow communication toward database on default security group
resource "aws_security_group_rule" "database" {
  security_group_id = var.default_security_group_id

  self      = true
  type      = "ingress"
  protocol  = "TCP"
  from_port = local.database_port
  to_port   = local.database_port
}
