variable "aws_region" {
  description = "AWS region para deploy"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Nome do ambiente (dev, prod, etc)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "kong-gateway"
}

variable "kong_image" {
  description = "Imagem Docker do Kong"
  type        = string
  default     = "kong:3.10.0.4" # Kong Gateway 3.10.0.4 com Manager OSS bundled
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

variable "allowed_cidr_blocks" {
  description = "CIDR blocks permitidos para acesso ao Kong"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Internet access - ajuste conforme necessário
}

# RDS Variables
variable "db_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro" # Free tier eligible
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
