# Outputs - Secret Manager

output "jwt_secret_arn" {
  description = "ARN do JWT secret no Secrets Manager"
  value       = aws_secretsmanager_secret.jwt_secret.arn
}

output "jwt_secret_name" {
  description = "Nome do JWT secret"
  value       = aws_secretsmanager_secret.jwt_secret.name
}

output "jwt_secret_value" {
  description = "Valor do JWT Secret gerado (sensível)"
  value       = random_password.jwt_secret.result
  sensitive   = true
}
