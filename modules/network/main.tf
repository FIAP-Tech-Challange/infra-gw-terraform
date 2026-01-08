# Data sources para usar recursos existentes da AWS
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_subnet" "default" {
  for_each = toset(data.aws_subnets.default.ids)
  id       = each.value
}

# Security Group padrão da VPC
data "aws_security_group" "default" {
  filter {
    name   = "group-name"
    values = ["default"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group para o Kong (aceita conexões da internet)
resource "aws_security_group" "kong" {
  name_prefix = "${var.project_name}-kong-"
  description = "Security group para Kong Gateway - aceita conexoes da internet"
  vpc_id      = data.aws_vpc.default.id

  # HTTP - Kong Proxy
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Kong Proxy HTTP"
  }

  # HTTPS - Kong Proxy  
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "Kong Proxy HTTPS"
  }

  # Kong Admin API (restrito - apenas para debugging/management)
  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Em produção, restringir a IPs específicos
    description = "Kong Admin API"
  }

  # Kong Manager OSS - Interface Web
  ingress {
    from_port   = 8002
    to_port     = 8002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Interface web para gerenciamento
    description = "Kong Manager OSS UI"
  }

  # HTTP para Load Balancer Health Check
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP Load Balancer"
  }

  # Egress - Kong precisa acessar backends e outros serviços
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-kong-sg"
    Environment = var.environment
  }
}

# Security Group para ALB
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-alb-"
  description = "Security group para Application Load Balancer"
  vpc_id      = data.aws_vpc.default.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  # HTTPS  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  # Kong Admin API
  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kong Admin API"
  }

  # Kong Manager
  ingress {
    from_port   = 8002
    to_port     = 8002
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kong Manager"
  }

  # Egress para Kong
  egress {
    from_port       = 8000
    to_port         = 8002
    protocol        = "tcp"
    security_groups = [aws_security_group.kong.id]
    description     = "To Kong containers"
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Environment = var.environment
  }
}

# Security Group Rules para o default security group

resource "aws_security_group_rule" "default_from_kong_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kong.id
  security_group_id        = data.aws_security_group.default.id
  description              = "HTTP from Kong"
}

resource "aws_security_group_rule" "default_from_kong_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kong.id
  security_group_id        = data.aws_security_group.default.id
  description              = "HTTPS from Kong"
}

resource "aws_security_group_rule" "default_from_kong_custom_ports" {
  type                     = "ingress"
  from_port                = 8000
  to_port                  = 9999
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.kong.id
  security_group_id        = data.aws_security_group.default.id
  description              = "Custom ports from Kong for backend services"
}

resource "aws_security_group_rule" "default_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
  description       = "SSH access"
}

# Egress rule para permitir acesso à internet (pull de imagens, APIs, etc)
resource "aws_security_group_rule" "default_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
  description       = "Allow all outbound traffic for Docker pulls, package installs, API calls, etc"
}
