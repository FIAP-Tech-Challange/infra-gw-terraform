# ECS Module Variables

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, prod, etc)"
  type        = string
}

variable "aws_region" {
  description = "AWS region para deploy"
  type        = string
}

variable "kong_image" {
  description = "Imagem Docker do Kong"
  type        = string
  default     = "kong:3.10.0.4"
}

variable "kong_cpu" {
  description = "CPU para o container Kong (em CPU units)"
  type        = number
  default     = 512
}

variable "kong_memory" {
  description = "Memória para o container Kong (em MB)"
  type        = number
  default     = 1024
}

variable "kong_desired_count" {
  description = "Número desejado de instâncias Kong"
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "IDs das subnets para o ECS"
  type        = list(string)
}

variable "kong_security_group_id" {
  description = "ID do Security Group do Kong"
  type        = string
}

variable "target_group_arn_proxy" {
  description = "ARN do Target Group para Kong Proxy"
  type        = string
}

variable "target_group_arn_admin" {
  description = "ARN do Target Group para Kong Admin"
  type        = string
}

variable "target_group_arn_manager" {
  description = "ARN do Target Group para Kong Manager"
  type        = string
}

variable "lab_role_arn" {
  description = "ARN da LabRole para AWS Academy"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN do secret no AWS Secrets Manager"
  type        = string
}

variable "db_endpoint" {
  description = "Endpoint do banco de dados"
  type        = string
}

variable "db_port" {
  description = "Porta do banco de dados"
  type        = number
}

variable "db_name" {
  description = "Nome do banco de dados"
  type        = string
}
