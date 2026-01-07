# Network Module Variables

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (dev, prod, etc)"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks permitidos para acesso ao Kong"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
