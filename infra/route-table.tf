resource "aws_route_table" "route_table_publica" {
  vpc_id = aws_vpc.vpc_principal.id

  route {
    cidr_block = aws_vpc.vpc_principal.cidr_block
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0" # Rota padrão para todo o tráfego IPv4
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name              = "Route Table Pública"
    ProjectIdentifier = var.project_identifier
  }
}

resource "aws_route_table_association" "route_table_association" {
  # A expressão 'for_each' transforma a lista de subnets em um mapa.
  # O resultado real para o Terraform será um mapa onde a key é o index
  # e o value é o objeto completo da subnet, com todos os seus atributos:
  # {
  #   "0" = { id = "subnet-0a1b2c3d...", arn = "...", cidr_block = "10.0.0.0/20", availability_zone = "us-east-1a", ... },
  #   "1" = { id = "subnet-0e1f2g3h...", arn = "...", cidr_block = "10.0.16.0/20", availability_zone = "us-east-1b", ... },
  #   "2" = { id = "subnet-0i1j2k3l...", arn = "...", cidr_block = "10.0.32.0/20", availability_zone = "us-east-1c", ... }
  # }
  for_each       = { for index, subnet in aws_subnet.subnet_publica : index => subnet }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.route_table_publica.id
}