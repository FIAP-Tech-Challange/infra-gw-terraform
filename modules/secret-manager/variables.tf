variable "api_key_secret_name" {
  description = "The name of the API key secret in AWS Secrets Manager"
  type        = string
}

variable "jwtSecretName" {
  description = "The name of the JWT secret in AWS Secrets Manager"
  type        = string
}