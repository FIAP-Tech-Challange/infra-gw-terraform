variable "repository_name" {
  description = "Nome do repositório ECR"
  type        = string
  default     = "microservices-snack-bar"
}

variable "environment" {
  description = "Ambiente (dev, staging, production)"
  type        = string
  default     = "production"
}
