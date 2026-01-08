output "repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.microservices_snack_bar.repository_url
}

output "repository_arn" {
  description = "ARN do repositório ECR"
  value       = aws_ecr_repository.microservices_snack_bar.arn
}

output "repository_name" {
  description = "Nome do repositório ECR"
  value       = aws_ecr_repository.microservices_snack_bar.name
}

output "registry_id" {
  description = "ID do registry ECR"
  value       = aws_ecr_repository.microservices_snack_bar.registry_id
}
