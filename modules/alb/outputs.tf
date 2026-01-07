output "load_balancer_arn" {
  description = "ARN do Load Balancer"
  value       = aws_lb.kong.arn
}

output "load_balancer_dns" {
  description = "DNS do Load Balancer"
  value       = aws_lb.kong.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID do Load Balancer"
  value       = aws_lb.kong.zone_id
}

output "kong_proxy_url" {
  description = "URL do Kong Proxy"
  value       = "http://${aws_lb.kong.dns_name}"
}

output "kong_admin_url" {
  description = "URL da Kong Admin API"
  value       = "http://${aws_lb.kong.dns_name}:8001"
}

output "kong_manager_url" {
  description = "URL do Kong Manager"
  value       = "http://${aws_lb.kong.dns_name}:8002"
}

output "target_group_arn_proxy" {
  description = "ARN do Target Group para Kong Proxy"
  value       = aws_lb_target_group.kong_proxy.arn
}

output "target_group_arn_admin" {
  description = "ARN do Target Group para Kong Admin"
  value       = aws_lb_target_group.kong_admin.arn
}

output "target_group_arn_manager" {
  description = "ARN do Target Group para Kong Manager"
  value       = aws_lb_target_group.kong_manager.arn
}
