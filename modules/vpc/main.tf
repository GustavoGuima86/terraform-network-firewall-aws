resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )
}

# Public subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(
    {
      Name = "${var.vpc_name}-public"
    },
    var.tags
  )
}

# Private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(
    {
      Name = "${var.vpc_name}-private"
    },
    var.tags
  )
}

# Attachment subnet (for TGW and Network Firewall)
resource "aws_subnet" "attachment" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.attachment_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(
    {
      Name = "${var.vpc_name}-attachment"
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  count = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-igw"
    },
    var.tags
  )
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  count = var.create_nat_gateway ? 1 : 0
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.vpc_name}-nat-eip"
    },
    var.tags
  )
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  count = var.create_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public.id

  depends_on = [aws_internet_gateway.main]

  tags = merge(
    {
      Name = "${var.vpc_name}-nat"
    },
    var.tags
  )
}

# Route table for public subnet
resource "aws_route_table" "public" {
  count = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-public-rt"
    },
    var.tags
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_igw ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
}

resource "aws_route_table_association" "public" {
  count = var.create_igw ? 1 : 0
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public[0].id
}

# Route table for private subnet (default, will be modified by root module)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-private-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

# Route table for attachment subnet
resource "aws_route_table" "attachment" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-attachment-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "attachment" {
  subnet_id      = aws_subnet.attachment.id
  route_table_id = aws_route_table.attachment.id
}
