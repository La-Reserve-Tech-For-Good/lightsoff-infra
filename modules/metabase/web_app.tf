resource "aws_iam_role" "metabase" {
  name = "${local.name}-${local.environment}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_role_policy" "metabase" {
  role = aws_iam_role.metabase.name
  name = "${local.name}-${local.environment}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CWLogGroupManagement",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:DescribeLogGroups",
          "logs:PutRetentionPolicy"
        ],
        Resource = "arn:aws:logs:*:*:log-group:${local.name}-${local.environment}:*"
      },
      {
        Sid    = "CWLogStreamManagement",
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:log-group:${local.name}-${local.environment}:log-stream:${local.name}/${local.name}-container-${local.environment}/*"
      }
    ]
  })
}

resource "aws_ecs_cluster" "metabase" {
  name = local.name
}

resource "aws_ecs_cluster_capacity_providers" "metabase" {
  cluster_name = aws_ecs_cluster.metabase.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_ecs_task_definition" "metabase" {
  family                   = "${local.name}-${local.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 2048
  execution_role_arn       = aws_iam_role.metabase.arn

  container_definitions = jsonencode([
    {
      name      = "${local.name}-container-${local.environment}"
      image     = "metabase/metabase:v0.44.6"
      essential = true
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = local.web_app_port
        }
      ]
      environment = [
        { name = "MB_DB_TYPE", value = "postgres" },
        { name = "MB_DB_HOST", value = aws_db_instance.metabase.address },
        { name = "MB_DB_PORT", value = tostring(local.database_port) },
        { name = "MB_DB_USER", value = var.database_username },
        { name = "MB_DB_PASS", value = var.database_password },
        { name = "MB_DB_DBNAME", value = local.name },
        { name = "MB_ENCRYPTION_SECRET_KEY", value = var.encryption_key },
        { name = "MB_PASSWORD_COMPLEXITY", value = "strong" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region"        = var.aws_region
          "awslogs-group"         = "${local.name}-${local.environment}"
          "awslogs-stream-prefix" = local.name
          "awslogs-create-group"  = "true"
        }
      }
    }
  ])
}
resource "aws_service_discovery_private_dns_namespace" "metabase" {
  name = "${local.name}-${local.environment}"
  vpc  = var.default_vpc_id
}

resource "aws_service_discovery_service" "metabase" {
  name = "${local.name}-${local.environment}"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.metabase.id

    dns_records {
      ttl  = 60
      type = "SRV"
    }
  }
}

resource "aws_apigatewayv2_vpc_link" "metabase" {
  name               = "${local.name}-${local.environment}"
  security_group_ids = [aws_security_group.metabase_sg.id]
  subnet_ids = [
    var.subnet_a_id,
    # This is is not working for some reason..
    # var.subnet_b_id,
    var.subnet_c_id
  ]
}

resource "aws_apigatewayv2_api" "metabase" {
  name          = "${local.name}-${local.environment}"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "metabase" {
  api_id      = aws_apigatewayv2_api.metabase.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_route" "metabase" {
  api_id    = aws_apigatewayv2_api.metabase.id
  route_key = "$default"

  target = "integrations/${aws_apigatewayv2_integration.metabase.id}"
}

resource "aws_apigatewayv2_integration" "metabase" {
  api_id           = aws_apigatewayv2_api.metabase.id
  integration_type = "HTTP_PROXY"
  integration_uri  = aws_service_discovery_service.metabase.arn

  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.metabase.id
}

resource "aws_ecs_service" "metabase" {
  name                               = local.name
  cluster                            = aws_ecs_cluster.metabase.id
  task_definition                    = aws_ecs_task_definition.metabase.arn
  desired_count                      = 1
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  network_configuration {
    subnets          = [var.subnet_a_id, var.subnet_b_id, var.subnet_c_id]
    security_groups  = [aws_security_group.metabase_sg.id]
    assign_public_ip = true
  }

  service_registries {
    registry_arn = aws_service_discovery_service.metabase.arn
    port         = local.web_app_port
  }
}

resource "aws_security_group" "metabase_sg" {
  name        = "allow_metabase_access-${local.name}-${local.environment}"
  description = "Allow metabase inbound traffic"

  # Allow access container from anywhere on ANY TCP port (not sure why HTTPS only does not work)
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"
    from_port   = 0
    to_port     = 65535
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }
}
