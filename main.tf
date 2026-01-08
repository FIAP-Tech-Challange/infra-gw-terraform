# Main Configuration - Kong Gateway

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Configuração compatível com CI/CD e desenvolvimento local
  # As credenciais podem vir de:
  # - Variáveis de ambiente (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_SESSION_TOKEN) para CI/CD
  # - Arquivos de credenciais locais (~/.aws/credentials) para desenvolvimento local

  default_tags {
    tags = {
      Project     = "Kong-Gateway"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# Módulo Network - VPC, Security Groups, etc.
module "network" {
  source = "./modules/network"

  project_name        = var.project_name
  environment         = var.environment
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

# Módulo IAM - Roles necessárias
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

# Módulo RDS - PostgreSQL Database
module "rds" {
  source = "./modules/rds"

  project_name             = var.project_name
  environment              = var.environment
  vpc_id                   = module.network.vpc_id
  subnet_ids               = module.network.subnet_ids
  kong_security_group_id   = module.network.kong_security_group_id
  db_instance_class        = var.db_instance_class
  db_allocated_storage     = var.db_allocated_storage
  db_max_allocated_storage = var.db_max_allocated_storage
  db_backup_retention_days = var.db_backup_retention_days
}

# Módulo ALB - Application Load Balancer
module "alb" {
  source = "./modules/alb"

  project_name          = var.project_name
  environment           = var.environment
  vpc_id                = module.network.vpc_id
  subnet_ids            = module.network.subnet_ids
  alb_security_group_id = module.network.alb_security_group_id
}

# Módulo ECS - Kong Gateway Container
module "ecs" {
  source = "./modules/ecs"

  project_name             = var.project_name
  environment              = var.environment
  aws_region               = var.aws_region
  kong_image               = var.kong_image
  kong_cpu                 = var.kong_cpu
  kong_memory              = var.kong_memory
  kong_desired_count       = var.kong_desired_count
  subnet_ids               = module.network.subnet_ids
  kong_security_group_id   = module.network.kong_security_group_id
  target_group_arn_proxy   = module.alb.target_group_arn_proxy
  target_group_arn_admin   = module.alb.target_group_arn_admin
  target_group_arn_manager = module.alb.target_group_arn_manager
  lab_role_arn             = module.iam.lab_role_arn
  db_secret_arn            = module.rds.db_secret_arn
  db_endpoint              = module.rds.db_instance_endpoint
  db_port                  = module.rds.db_instance_port
  db_name                  = module.rds.db_instance_name
}

# Módulo ECR - Container Registry
module "ecr" {
  source = "./modules/ecr"

  repository_name = "microservices-snack-bar"
  environment     = var.environment
}

# Módulo Secret Manager
module "secret_manager" {
  source        = "./modules/secret-manager"
  jwtSecretName = var.jwtSecretName
}
