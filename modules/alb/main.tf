# Application Load Balancer
resource "aws_lb" "kong" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets           = var.subnet_ids

  enable_deletion_protection = false

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
  }
}

# Target Group para Kong Proxy
resource "aws_lb_target_group" "kong_proxy" {
  name        = "${var.project_name}-proxy-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2          
    interval            = 120        
    matcher             = "200,404"  
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
    unhealthy_threshold = 10
  }

  tags = {
    Name        = "${var.project_name}-proxy-target-group"
    Environment = var.environment
  }
}

# Target Group para Kong Admin API
resource "aws_lb_target_group" "kong_admin" {
  name        = "${var.project_name}-admin-tg"
  port        = 8001
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2          
    interval            = 120        
    matcher             = "200"
    path                = "/status"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
    unhealthy_threshold = 10         
  }

  tags = {
    Name        = "${var.project_name}-admin-target-group"
    Environment = var.environment
  }
}

# Target Group para Kong Manager OSS (GUI)
resource "aws_lb_target_group" "kong_manager" {
  name        = "${var.project_name}-manager-tg"
  port        = 8002
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 120
    matcher             = "200,404"  
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 30
    unhealthy_threshold = 10
  }

  tags = {
    Name        = "${var.project_name}-manager-target-group"
    Environment = var.environment
  }
}

# Listener HTTP para Proxy (porta 80)
resource "aws_lb_listener" "kong_proxy_http" {
  load_balancer_arn = aws_lb.kong.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kong_proxy.arn
  }

  tags = {
    Name        = "${var.project_name}-proxy-listener"
    Environment = var.environment
  }
}

# Listener HTTP para Admin API (porta 8001)
resource "aws_lb_listener" "kong_admin_http" {
  load_balancer_arn = aws_lb.kong.arn
  port              = "8001"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kong_admin.arn
  }

  tags = {
    Name        = "${var.project_name}-admin-listener"
    Environment = var.environment
  }
}

# Listener HTTP para Kong Manager OSS (porta 8002)
resource "aws_lb_listener" "kong_manager_http" {
  load_balancer_arn = aws_lb.kong.arn
  port              = "8002"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kong_manager.arn
  }

  tags = {
    Name        = "${var.project_name}-manager-listener"
    Environment = var.environment
  }
}
