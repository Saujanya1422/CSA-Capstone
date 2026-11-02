resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "${var.name}-vpc" })
}
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, { Name = "${var.name}-igw" })
}
resource "aws_subnet" "public_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = var.az1
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "${var.name}-public-a" })
}
resource "aws_subnet" "public_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = var.az2
  map_public_ip_on_launch = true
  tags = merge(var.tags, { Name = "${var.name}-public-b" })
}
resource "aws_subnet" "app" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 10)
  availability_zone = var.az1
  tags = merge(var.tags, { Name = "${var.name}-private-app" })
}
resource "aws_subnet" "db_a" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 20)
  availability_zone = var.az1
  tags = merge(var.tags, { Name = "${var.name}-private-db-a" })
}
resource "aws_subnet" "db_b" {
  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 21)
  availability_zone = var.az2
  tags = merge(var.tags, { Name = "${var.name}-private-db-b" })
}
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(var.tags, { Name = "${var.name}-nat-eip" })
}
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_a.id
  depends_on = [aws_internet_gateway.main]
  tags = merge(var.tags, { Name = "${var.name}-nat" })
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(var.tags, { Name = "${var.name}-public-rt" })
}
resource "aws_route_table_association" "public_a" {
  subnet_id = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_b" {
  subnet_id = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table" "app" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = merge(var.tags, { Name = "${var.name}-app-private-rt" })
}
resource "aws_route_table_association" "app" {
  subnet_id = aws_subnet.app.id
  route_table_id = aws_route_table.app.id
}
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, { Name = "${var.name}-db-isolated-rt" })
}
resource "aws_route_table_association" "db_a" {
  subnet_id = aws_subnet.db_a.id
  route_table_id = aws_route_table.db.id
}
resource "aws_route_table_association" "db_b" {
  subnet_id = aws_subnet.db_b.id
  route_table_id = aws_route_table.db.id
}
