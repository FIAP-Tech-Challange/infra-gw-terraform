terraform {
  backend "s3" {
    bucket  = "terraform-state-fiap-kong-gw"
    key     = "infra-gw/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
