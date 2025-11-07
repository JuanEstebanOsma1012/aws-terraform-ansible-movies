# ------------------------------
# VPC (Principal)
# ------------------------------
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/24"
  tags = { Name = "prod-vpc" }
}

# ------------------------------
# Subnets (Publica y privada)
# ------------------------------
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = [
    "192.168.0.0/26",
    "192.168.0.64/26"
  ][count.index]
  availability_zone = ["us-east-1a", "us-east-1b"][count.index]
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-${count.index}" }
}

resource "aws_subnet" "private" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = [
    "192.168.0.128/26",
    "192.168.0.192/26"
  ][count.index]
  availability_zone = ["us-east-1a", "us-east-1b"][count.index]
  tags = { Name = "private-subnet-${count.index}" }
}

# ------------------------------
# Internet Gateway & Route Table pública
# ------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "main-igw" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-rt" }
}

resource "aws_route_table_association" "public" {
  count = 2
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ------------------------------
# NAT Gateway para subred privada
# ------------------------------
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = { Name = "main-nat" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "private-rt" }
}

resource "aws_route_table_association" "private" {
  count = 2
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
