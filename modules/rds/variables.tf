# RDS Module Variables

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
  description = "IDs das subnets para o RDS"
  type        = list(string)
}

variable "kong_security_group_id" {
  description = "ID do Security Group do Kong"
  type        = string
}

variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Storage inicial do RDS (GB)"
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Storage máximo do RDS (GB) para auto-scaling"
  type        = number
  default     = 100
}

variable "db_backup_retention_days" {
  description = "Dias de retenção de backup"
  type        = number
  default     = 7
}
