resource "aws_security_group" "metabase_database_sg" {
  name        = "allow_database_access-${local.name}-${local.environment}"
  description = "Allow database inbound traffic from VPC"

  # Allow access database from VPC
  ingress {
    security_groups = [aws_security_group.metabase_sg.id]
    protocol        = "TCP"
    from_port       = local.database_port
    to_port         = local.database_port
  }

  egress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }
}

resource "aws_db_instance" "metabase" {
  identifier              = "${local.name}-${local.environment}"
  allocated_storage       = local.allocated_storage
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

  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.metabase_database_sg.id]
}
