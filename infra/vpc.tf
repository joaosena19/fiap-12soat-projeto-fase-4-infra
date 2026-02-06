resource "aws_vpc" "vpc_principal" {
  cidr_block           = var.cidr_vpc
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name              = "VPC Principal ${var.project_name}"
    ProjectIdentifier = var.project_identifier
  }
}