resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 6, count.index) # Using /22 subnet mask to have 4 subnets in each availability zone
  availability_zone = element(var.aws_availability_zones, count.index % length(var.aws_availability_zones))
}

resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 6, count.index + 3)
  availability_zone = element(var.aws_availability_zones, count.index % length(var.aws_availability_zones))
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.aws_availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public[*].id, count.index)
}

resource "aws_eip" "nat" {
  count = length(var.aws_availability_zones)
  vpc = true
}

resource "aws_route_table" "private" {
  count = length(var.aws_availability_zones)
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-${count.index}"
  }
}

resource "aws_route" "private_nat" {
  count            = length(var.aws_availability_zones) * 3
  route_table_id   = element(aws_route_table.private[*].id, count.index % length(var.aws_availability_zones))
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id  = element(aws_nat_gateway.nat[*].id, count.index % length(var.aws_availability_zones))
}

variable "aws_availability_zones" {
  type    = list(string)
  default = ["us-west-2a", "us-west-2b", "us-west-2c"]
}