# IAM Module Variables

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, prod, etc)"
  type        = string
}
