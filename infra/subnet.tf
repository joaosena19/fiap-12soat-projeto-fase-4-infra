resource "aws_subnet" "subnet_publica" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.vpc_principal.id
  cidr_block              = cidrsubnet(aws_vpc.vpc_principal.cidr_block, 4, count.index)
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zones[count.index]

  tags = {
    Name              = "Subnet Publica ${count.index + 1}"
    ProjectIdentifier = var.project_identifier
  }
}