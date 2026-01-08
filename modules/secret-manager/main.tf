# ------------------------------
# JWT Secret
# ------------------------------
resource "aws_secretsmanager_secret" "jwt_secret" {
  name                           = var.jwtSecretName
  force_overwrite_replica_secret = true

  tags = {
    Name      = var.jwtSecretName
    Type      = "JWT Secret"
    ManagedBy = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "jwt_secret_version" {
  secret_id     = aws_secretsmanager_secret.jwt_secret.id
  secret_string = random_password.jwt_secret.result
}

resource "random_password" "jwt_secret" {
  length  = 64    # JWT secrets are typically longer
  special = false # JWT secrets usually don't need special characters
}
