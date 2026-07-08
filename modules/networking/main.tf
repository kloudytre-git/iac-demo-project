# Look up which availability zones exist in the current region
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  az_count = length(var.public_subnet_cidrs)
  name     = "${var.project}-${var.environment}"
}

# --- VPC ---
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${local.name}-vpc"
    project     = var.project
    environment = var.environment
  }
}

# --- Public subnets (one per AZ) ---
resource "aws_subnet" "public" {
  count                   = local.az_count
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.name}-public-${count.index + 1}"
    project     = var.project
    environment = var.environment
    tier        = "public"
  }
}

# --- Private subnets (one per AZ) ---
resource "aws_subnet" "private" {
  count             = local.az_count
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${local.name}-private-${count.index + 1}"
    project     = var.project
    environment = var.environment
    tier        = "private"
  }
}

# --- Internet Gateway (gives public subnets internet access) ---
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name        = "${local.name}-igw"
    project     = var.project
    environment = var.environment
  }
}

# --- NAT Gateway (lets private subnets reach OUT, but not be reached) ---
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name        = "${local.name}-nat-eip"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.this]

  tags = {
    Name        = "${local.name}-nat"
    project     = var.project
    environment = var.environment
  }
}

# --- Public route table: send internet traffic to the IGW ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name        = "${local.name}-public-rt"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_route_table_association" "public" {
  count          = local.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# --- Private route table: send internet traffic to the NAT ---
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name        = "${local.name}-private-rt"
    project     = var.project
    environment = var.environment
  }
}

resource "aws_route_table_association" "private" {
  count          = local.az_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}