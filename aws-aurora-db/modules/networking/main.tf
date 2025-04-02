# AWS Networking Module for Aurora PostgreSQL
# This module creates VPC networking components for Aurora clusters

# VPC for the Aurora Cluster
resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-vpc"
    },
  )
}

# Internet Gateway for the VPC
resource "aws_internet_gateway" "this" {
  count = var.create_vpc && var.create_igw ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-igw"
    },
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = var.create_vpc ? length(var.public_subnet_cidrs) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-public-subnet-${count.index + 1}"
      "Type" = "Public"
    },
  )
}

# Private Subnets for Aurora DB
resource "aws_subnet" "private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  vpc_id                  = aws_vpc.this[0].id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-private-subnet-${count.index + 1}"
      "Type" = "Private"
    },
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.create_vpc && var.create_nat_gateway ? length(var.public_subnet_cidrs) : 0

  domain = "vpc"

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-nat-eip-${count.index + 1}"
    },
  )
}

# NAT Gateways in Public Subnets
resource "aws_nat_gateway" "this" {
  count = var.create_vpc && var.create_nat_gateway ? length(var.public_subnet_cidrs) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-nat-gw-${count.index + 1}"
    },
  )

  depends_on = [aws_internet_gateway.this]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  count = var.create_vpc ? 1 : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-public-rt"
    },
  )
}

# Route for Internet Access from Public Subnets
resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && var.create_igw ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

# Associate Public Route Table with Public Subnets
resource "aws_route_table_association" "public" {
  count = var.create_vpc ? length(var.public_subnet_cidrs) : 0

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[0].id
}

# Route Tables for Private Subnets
resource "aws_route_table" "private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  vpc_id = aws_vpc.this[0].id

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-private-rt-${count.index + 1}"
    },
  )
}

# Route for Internet Access from Private Subnets via NAT Gateway
resource "aws_route" "private_nat_gateway" {
  count = var.create_vpc && var.create_nat_gateway ? length(var.private_subnet_cidrs) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id

  timeouts {
    create = "5m"
  }
}

# Associate Private Route Tables with Private Subnets
resource "aws_route_table_association" "private" {
  count = var.create_vpc ? length(var.private_subnet_cidrs) : 0

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security Group for Aurora DB
resource "aws_security_group" "db" {
  count = var.create_security_group ? 1 : 0

  name        = "${var.name}-db-sg"
  description = "Security group for ${var.name} Aurora PostgreSQL"
  vpc_id      = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  ingress {
    description = "PostgreSQL from allowed CIDR blocks"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description     = "PostgreSQL from security group"
    from_port       = var.db_port
    to_port         = var.db_port
    protocol        = "tcp"
    security_groups = var.allowed_security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-db-sg"
    },
  )
}

# Security Group for Application Access to DB
resource "aws_security_group" "app" {
  count = var.create_security_group && var.create_app_security_group ? 1 : 0

  name        = "${var.name}-app-sg"
  description = "Security group for applications accessing ${var.name} Aurora PostgreSQL"
  vpc_id      = var.create_vpc ? aws_vpc.this[0].id : var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      "Name" = "${var.name}-app-sg"
    },
  )
}

# Security Group Rules for Application Access to DB
resource "aws_security_group_rule" "app_to_db" {
  count = var.create_security_group && var.create_app_security_group ? 1 : 0

  type                     = "egress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.db[0].id
  security_group_id        = aws_security_group.app[0].id
}

resource "aws_security_group_rule" "db_from_app" {
  count = var.create_security_group && var.create_app_security_group ? 1 : 0

  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app[0].id
  security_group_id        = aws_security_group.db[0].id
}
