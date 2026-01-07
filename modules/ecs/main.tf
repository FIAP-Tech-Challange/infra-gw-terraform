# ECS Cluster
resource "aws_ecs_cluster" "kong" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name        = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

# CloudWatch Log Group para Kong
resource "aws_cloudwatch_log_group" "kong" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-logs"
    Environment = var.environment
  }
}

# Task Definition para Kong Gateway OSS
resource "aws_ecs_task_definition" "kong" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.kong_cpu
  memory                   = var.kong_memory
  execution_role_arn       = var.lab_role_arn
  task_role_arn            = var.lab_role_arn

  container_definitions = jsonencode([
    {
      name      = "kong-migrations"
      image     = var.kong_image
      essential = false

      command = ["kong", "migrations", "bootstrap"]

      environment = [
        {
          name  = "KONG_DATABASE"
          value = "postgres"
        },
        {
          name  = "KONG_PG_HOST"
          value = split(":", var.db_endpoint)[0]
        },
        {
          name  = "KONG_PG_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "KONG_PG_DATABASE"
          value = var.db_name
        },
        {
          name  = "KONG_PG_SSL"
          value = "on"
        },
        {
          name  = "KONG_PG_SSL_VERIFY"
          value = "off"
        }
      ]

      # Secrets do AWS Secrets Manager
      secrets = [
        {
          name      = "KONG_PG_USER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "KONG_PG_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.kong.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "migrations"
        }
      }
    },
    {
      name      = "kong"
      image     = var.kong_image
      essential = true

      # Kong depende das migrations completarem
      dependsOn = [
        {
          containerName = "kong-migrations"
          condition     = "SUCCESS"
        }
      ]

      # Kong com PostgreSQL/RDS
      environment = [
        {
          name  = "KONG_DATABASE"
          value = "postgres"
        },
        {
          name  = "KONG_PG_HOST"
          value = split(":", var.db_endpoint)[0]
        },
        {
          name  = "KONG_PG_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "KONG_PG_DATABASE"
          value = var.db_name
        },
        {
          name  = "KONG_PROXY_ACCESS_LOG"
          value = "/dev/stdout"
        },
        {
          name  = "KONG_ADMIN_ACCESS_LOG"
          value = "/dev/stdout"
        },
        {
          name  = "KONG_PROXY_ERROR_LOG"
          value = "/dev/stderr"
        },
        {
          name  = "KONG_ADMIN_ERROR_LOG"
          value = "/dev/stderr"
        },
        {
          name  = "KONG_ADMIN_LISTEN"
          value = "0.0.0.0:8001"
        },
        {
          name  = "KONG_PLUGINS"
          value = "bundled"
        },
        {
          name  = "KONG_LOG_LEVEL"
          value = "info"
        },
        {
          name  = "KONG_PG_SSL"
          value = "on"
        },
        {
          name  = "KONG_PG_SSL_VERIFY"
          value = "off"
        },
        {
          name  = "KONG_ADMIN_GUI_LISTEN"
          value = "0.0.0.0:8002"
        },
        {
          name  = "KONG_ADMIN_GUI_PATH"
          value = "/"
        }
      ]

      # Secrets do AWS Secrets Manager
      secrets = [
        {
          name      = "KONG_PG_USER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "KONG_PG_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]

      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        },
        {
          containerPort = 8443
          protocol      = "tcp"
        },
        {
          containerPort = 8001
          protocol      = "tcp"
        },
        {
          containerPort = 8002
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command     = ["CMD", "kong", "health"]
        interval    = 90
        timeout     = 15
        retries     = 10
        startPeriod = 300
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.kong.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }

      essential = true
    }
  ])

  tags = {
    Name        = "${var.project_name}-task-definition"
    Environment = var.environment
  }
}

# Task Definition para Kong Migrations (executar migrações no banco)
resource "aws_ecs_task_definition" "kong_migrations" {
  family                   = "${var.project_name}-migrations"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.lab_role_arn
  task_role_arn            = var.lab_role_arn

  container_definitions = jsonencode([
    {
      name  = "kong-migrations"
      image = var.kong_image

      command = ["kong", "migrations", "bootstrap"]

      environment = [
        {
          name  = "KONG_DATABASE"
          value = "postgres"
        },
        {
          name  = "KONG_PG_HOST"
          value = split(":", var.db_endpoint)[0]
        },
        {
          name  = "KONG_PG_PORT"
          value = tostring(var.db_port)
        },
        {
          name  = "KONG_PG_DATABASE"
          value = var.db_name
        },
        {
          name  = "KONG_PG_SSL"
          value = "on"
        },
        {
          name  = "KONG_PG_SSL_VERIFY"
          value = "off"
        },
        {
          name  = "KONG_PLUGINS"
          value = "bundled"
        }
      ]

      # Secrets do AWS Secrets Manager
      secrets = [
        {
          name      = "KONG_PG_USER"
          valueFrom = "${var.db_secret_arn}:username::"
        },
        {
          name      = "KONG_PG_PASSWORD"
          valueFrom = "${var.db_secret_arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.kong.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "migrations"
        }
      }

      essential = true
    }
  ])

  tags = {
    Name        = "${var.project_name}-migrations-task"
    Environment = var.environment
  }
}

# ECS Service para Kong Gateway
resource "aws_ecs_service" "kong" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.kong.id
  task_definition = aws_ecs_task_definition.kong.arn
  desired_count   = var.kong_desired_count
  launch_type     = "FARGATE"

  # Configuração de rede
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.kong_security_group_id]
    assign_public_ip = true
  }

  # Load Balancer Target Groups
  load_balancer {
    target_group_arn = var.target_group_arn_proxy
    container_name   = "kong"
    container_port   = 8000
  }

  load_balancer {
    target_group_arn = var.target_group_arn_admin
    container_name   = "kong"
    container_port   = 8001
  }

  load_balancer {
    target_group_arn = var.target_group_arn_manager
    container_name   = "kong"
    container_port   = 8002
  }

  # Configuração de deployment
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  # Aguarda target groups estarem criados
  depends_on = [
    aws_ecs_task_definition.kong
  ]

  tags = {
    Name        = "${var.project_name}-ecs-service"
    Environment = var.environment
  }
}
