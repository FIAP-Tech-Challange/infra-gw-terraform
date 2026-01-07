output "vpc_id" {
  description = "ID da VPC default utilizada"
  value       = data.aws_vpc.default.id
}

output "vpc_cidr_block" {
  description = "CIDR block da VPC"
  value       = data.aws_vpc.default.cidr_block
}

output "subnet_ids" {
  description = "IDs das subnets default"
  value       = data.aws_subnets.default.ids
}

output "kong_security_group_id" {
  description = "ID do Security Group do Kong"
  value       = aws_security_group.kong.id
}

output "alb_security_group_id" {
  description = "ID do Security Group do ALB"
  value       = aws_security_group.alb.id
}

output "default_security_group_id" {
  description = "ID do Security Group padrão (para backends)"
  value       = data.aws_security_group.default.id
}
