terraform {
  backend "s3" {
    bucket = "fiap-12soat-fase4-joao-dainese"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

