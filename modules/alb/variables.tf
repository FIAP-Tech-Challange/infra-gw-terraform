# ALB Module Variables

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, prod, etc)"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC"
  type        = string
}

variable "subnet_ids" {
  description = "IDs das subnets para o ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  type        = string
}
