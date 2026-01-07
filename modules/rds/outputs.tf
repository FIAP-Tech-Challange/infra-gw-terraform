output "db_instance_endpoint" {
  description = "Endpoint da instância RDS"
  value       = aws_db_instance.kong.endpoint
}

output "db_instance_port" {
  description = "Porta da instância RDS"
  value       = aws_db_instance.kong.port
}

output "db_instance_name" {
  description = "Nome do banco de dados"
  value       = aws_db_instance.kong.db_name
}

output "db_instance_username" {
  description = "Username do banco de dados"
  value       = aws_db_instance.kong.username
  sensitive   = true
}

output "db_instance_password" {
  description = "Password do banco de dados"
  value       = random_password.db_password.result
  sensitive   = true
}

output "db_security_group_id" {
  description = "ID do Security Group do RDS"
  value       = aws_security_group.rds.id
}

output "db_secret_arn" {
  description = "ARN do secret no AWS Secrets Manager"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
