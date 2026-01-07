output "lab_role_arn" {
  description = "ARN da LabRole para AWS Academy"
  value       = data.aws_iam_role.lab_role.arn
}
