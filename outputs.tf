# Outputs - Kong Gateway

# Network outputs
output "vpc_id" {
  description = "ID da VPC default utilizada"
  value       = module.network.vpc_id
}

output "kong_security_group_id" {
  description = "ID do Security Group do Kong"
  value       = module.network.kong_security_group_id
}

output "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  value       = module.network.alb_security_group_id
}

output "default_security_group_id" {
  description = "ID do Security Group padrão (para backends)"
  value       = module.network.default_security_group_id
}

# ALB outputs
output "load_balancer_dns" {
  description = "DNS do Load Balancer"
  value       = module.alb.load_balancer_dns
}

output "load_balancer_zone_id" {
  description = "Zone ID do Load Balancer"
  value       = module.alb.load_balancer_zone_id
}

output "kong_proxy_url" {
  description = "URL do Kong Proxy"
  value       = module.alb.kong_proxy_url
}

output "kong_admin_url" {
  description = "URL da Kong Admin API"
  value       = module.alb.kong_admin_url
}

output "kong_manager_url" {
  description = "URL do Kong Manager"
  value       = module.alb.kong_manager_url
}

# RDS outputs
output "db_endpoint" {
  description = "Endpoint da instância RDS"
  value       = module.rds.db_instance_endpoint
}

output "db_secret_arn" {
  description = "ARN do secret no AWS Secrets Manager"
  value       = module.rds.db_secret_arn
}

# ECS outputs
output "ecs_cluster_name" {
  description = "Nome do cluster ECS"
  value       = module.ecs.ecs_service_name
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = module.ecs.ecs_service_name
}

# IAM outputs
output "lab_role_arn" {
  description = "ARN da LabRole para AWS Academy"
  value       = module.iam.lab_role_arn
}

# ECR outputs
output "ecr_repository_url" {
  description = "URL do repositório ECR para microservices-snack-bar"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "Nome do repositório ECR"
  value       = module.ecr.repository_name
}

output "ecr_registry_id" {
  description = "ID do registry ECR"
  value       = module.ecr.registry_id
}

# Secret Manager outputs
output "jwt_secret_arn" {
  description = "ARN do JWT secret no Secrets Manager"
  value       = module.secret_manager.jwt_secret_arn
}

output "jwt_secret_name" {
  description = "Nome do JWT secret"
  value       = module.secret_manager.jwt_secret_name
}
