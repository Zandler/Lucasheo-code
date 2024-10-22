provider "aws" {
  region = "us-east-1" # Substituir pela região que você for usar
}

# VPC principal com um CIDR grande o suficiente para suportar várias subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16" # CIDR grande para permitir a criação de múltiplas subnets
}

# Internet Gateway para permitir acesso à Internet nas subnets públicas
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Criando subnets públicas e privadas em cada zona de disponibilidade (AZ)

# Subnets Públicas
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24" # Subnet pública na AZ us-east-1a
  map_public_ip_on_launch = true          # Atribuir IPs públicos automaticamente
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24" # Subnet pública na AZ us-east-1b
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24" # Subnet pública na AZ us-east-1c
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"
}

# Subnets Privadas
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24" # Subnet privada na AZ us-east-1a
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24" # Subnet privada na AZ us-east-1b
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24" # Subnet privada na AZ us-east-1c
  availability_zone = "us-east-1c"
}

# NAT Gateway para as subnets privadas (colocado em uma subnet pública)
resource "aws_eip" "nat_eip" {
  # Elastic IP para o NAT Gateway
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id     # Associar o EIP ao NAT Gateway
  subnet_id     = aws_subnet.public_a.id # Colocar o NAT Gateway na subnet pública
}

# Tabela de rotas para as subnets públicas (Internet Gateway)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # Rota para a Internet
    gateway_id = aws_internet_gateway.main.id
  }
}

# Associação das subnets públicas à tabela de rotas pública
resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_b_association" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_c_association" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_route_table.id
}

# Tabela de rotas para as subnets privadas (NAT Gateway)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0" # Rota para a Internet, via NAT Gateway
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

# Associação das subnets privadas à tabela de rotas privada
resource "aws_route_table_association" "private_a_association" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_b_association" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_c_association" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_route_table.id
}
