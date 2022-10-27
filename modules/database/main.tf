locals {
  allocated_storage     = 10
  max_allocated_storage = local.allocated_storage * 2
  name                  = "lightsoff"
  environment           = terraform.workspace
  database_port         = 5432
}

resource "aws_security_group" "database_sg" {
  name        = "allow_database_access-${local.environment}"
  description = "Allow database inbound traffic"

  # Allow access database from VPC
  ingress {
    self      = true
    protocol  = "TCP"
    from_port = local.database_port
    to_port   = local.database_port
  }

  # Allow access database from anywhere (yes, it's bad)
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "TCP"
    from_port   = local.database_port
    to_port     = local.database_port
  }

  egress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
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

  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.database_sg.id]
}
