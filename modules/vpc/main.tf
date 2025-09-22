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

# --- Subnets ---
resource "aws_subnet" "public" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-public-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-private-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_subnet" "attachment" {
  count             = length(var.attachment_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.attachment_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-attachment-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_subnet" "firewall" {
  count             = length(var.firewall_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.firewall_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-firewall-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

# --- Gateways ---
resource "aws_internet_gateway" "main" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-igw"
    },
    var.tags
  )
}

resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? length(var.public_subnet_cidrs) : 0
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.vpc_name}-nat-eip-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "main" {
  count         = var.create_nat_gateway ? length(var.public_subnet_cidrs) : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.main]

  tags = merge(
    {
      Name = "${var.vpc_name}-nat-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

# --- Route Tables ---
resource "aws_route_table" "public" {
  count  = var.create_igw ? length(var.public_subnet_cidrs) : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main[0].id
  }

  tags = merge(
    {
      Name = "${var.vpc_name}-public-rt-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "public" {
  count          = var.create_igw ? length(var.public_subnet_cidrs) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table" "private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-private-rt-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table" "attachment" {
  count  = length(var.attachment_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-attachment-rt-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "attachment" {
  count          = length(var.attachment_subnet_cidrs)
  subnet_id      = aws_subnet.attachment[count.index].id
  route_table_id = aws_route_table.attachment[count.index].id
}

resource "aws_route_table" "firewall" {
  count  = length(var.firewall_subnet_cidrs)
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-firewall-rt-${var.availability_zones[count.index]}"
    },
    var.tags
  )
}

resource "aws_route_table_association" "firewall" {
  count          = length(var.firewall_subnet_cidrs)
  subnet_id      = aws_subnet.firewall[count.index].id
  route_table_id = aws_route_table.firewall[count.index].id
}

# --- VPC Flow Logs (Self-Contained) ---
resource "aws_cloudwatch_log_group" "flow_log" {
  count = var.enable_flow_log ? 1 : 0
  name  = "/aws/vpc-flow-logs/${var.vpc_name}"

  tags = merge(
    {
      Name = "${var.vpc_name}-flow-log-group"
    },
    var.tags
  )
}

resource "aws_iam_role" "flow_log" {
  count = var.enable_flow_log ? 1 : 0
  name  = "${var.vpc_name}-flow-log-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = merge(
    {
      Name = "${var.vpc_name}-flow-log-role"
    },
    var.tags
  )
}

resource "aws_iam_role_policy" "flow_log" {
  count = var.enable_flow_log ? 1 : 0
  name  = "${var.vpc_name}-flow-log-policy"
  role  = aws_iam_role.flow_log[0].id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "${aws_cloudwatch_log_group.flow_log[0].arn}"
    }
  ]
}
EOF
}

resource "aws_flow_log" "main" {
  count = var.enable_flow_log ? 1 : 0

  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_log[0].arn
  iam_role_arn         = aws_iam_role.flow_log[0].arn # Corrected argument name
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  tags = merge(
    {
      Name = "${var.vpc_name}-flow-log"
    },
    var.tags
  )

  depends_on = [aws_iam_role_policy.flow_log]
}
