locals {
  name        = "lightsoff-api"
  environment = terraform.workspace
}

resource "aws_security_group" "api_lambda_sg" {
  name        = "${local.name}-${local.environment}"
  description = "Allow necessary traffic for API lambda"

  # Allow lambda to make HTTPS call
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "TCP"
    from_port   = 443
    to_port     = 443
  }

  # Allow lambda to send traffic to postgresql
  egress {
    protocol        = "TCP"
    from_port       = var.database_port
    to_port         = var.database_port
    security_groups = [var.database_sg_id]
  }
}

# Allow database to receive postgresql traffic from lambda
resource "aws_security_group_rule" "lambda_to_database" {
  type                     = "ingress"
  protocol                 = "TCP"
  from_port                = var.database_port
  to_port                  = var.database_port
  security_group_id        = var.database_sg_id
  source_security_group_id = aws_security_group.api_lambda_sg.id
}
