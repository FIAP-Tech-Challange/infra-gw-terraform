# ECR Repository Module
# Simple and easy to understand ECR configuration

resource "aws_ecr_repository" "microservices_snack_bar" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = var.repository_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Lifecycle policy to keep only recent images
resource "aws_ecr_lifecycle_policy" "microservices_snack_bar" {
  repository = aws_ecr_repository.microservices_snack_bar.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
