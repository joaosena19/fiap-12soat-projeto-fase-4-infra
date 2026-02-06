resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc_principal.id

  tags = {
    Name              = "Internet Gateway ${var.project_name}"
    ProjectIdentifier = var.project_identifier
  }
}