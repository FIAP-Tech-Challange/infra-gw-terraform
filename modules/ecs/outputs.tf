output "ecs_cluster_id" {
  description = "ID do cluster ECS"
  value       = aws_ecs_cluster.kong.id
}

output "ecs_cluster_arn" {
  description = "ARN do cluster ECS"
  value       = aws_ecs_cluster.kong.arn
}

output "ecs_service_name" {
  description = "Nome do serviço ECS"
  value       = aws_ecs_service.kong.name
}

output "ecs_service_id" {
  description = "ID do serviço ECS"
  value       = aws_ecs_service.kong.id
}

output "task_definition_arn" {
  description = "ARN da task definition do Kong"
  value       = aws_ecs_task_definition.kong.arn
}

output "migrations_task_definition_arn" {
  description = "ARN da task definition das migrações"
  value       = aws_ecs_task_definition.kong_migrations.arn
}

output "cloudwatch_log_group_name" {
  description = "Nome do CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.kong.name
}
