# RDS PostgreSQL para Kong Gateway

# Subnet Group para RDS (usando subnets default da VPC)
resource "aws_db_subnet_group" "kong" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
  }
}

# Security Group para RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  description = "Security group para RDS PostgreSQL - acesso apenas do Kong"
  vpc_id      = var.vpc_id

  # PostgreSQL port - apenas do Kong
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.kong_security_group_id]
    description     = "PostgreSQL access from Kong only"
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
  }
}

# Random password para o banco (excluindo caracteres problemáticos do RDS)
resource "random_password" "db_password" {
  length  = 16
  special = true
  override_special = "!#$%&*()-_=+[]{}<>:?"  # Exclui / @ " espaço
  
  # Evita regenerar senha se já existe
  lifecycle {
    ignore_changes = [
      length,
      special,
      override_special
    ]
  }
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "kong" {
  # Configurações básicas
  identifier     = "${var.project_name}-postgres"
  engine         = "postgres"
  engine_version = "15"
  instance_class = var.db_instance_class
  
  # Database configuration
  db_name  = "kong"
  username = "kong"
  password = random_password.db_password.result
  
  # Storage
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  
  # Network & Security
  db_subnet_group_name   = aws_db_subnet_group.kong.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  
  # Backup & Maintenance
  backup_retention_period = var.db_backup_retention_days
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  # Monitoring (desabilitado para AWS Academy - sem Enhanced Monitoring)
  monitoring_interval = 0
  
  # Performance Insights (básico, sem role IAM)
  performance_insights_enabled = false
  
  # Deletion protection (desabilitado para Academy)
  deletion_protection = false
  skip_final_snapshot = true
  
  # Auto minor version updates
  auto_minor_version_upgrade = true
  
  tags = {
    Name        = "${var.project_name}-postgres"
    Environment = var.environment
  }
}

# AWS Secrets Manager para armazenar credenciais do banco
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}-db-credentials"
  description             = "Credenciais do banco PostgreSQL para Kong"
  recovery_window_in_days = 0  # Permite delete imediato no Academy
  
  tags = {
    Name        = "${var.project_name}-db-credentials"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = aws_db_instance.kong.username
    password = random_password.db_password.result
    engine   = "postgres"
    host     = aws_db_instance.kong.endpoint
    port     = aws_db_instance.kong.port
    dbname   = aws_db_instance.kong.db_name
  })
}
