# Create the Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description = "${var.name_prefix}-tgw"

  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = merge(
    {
      Name = "${var.name_prefix}-tgw"
    },
    var.tags
  )
}

# Create TGW route tables
resource "aws_ec2_transit_gateway_route_table" "inspection" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    {
      Name = "${var.name_prefix}-inspection-rt"
    },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    {
      Name = "${var.name_prefix}-spoke-rt"
    },
    var.tags
  )
}

# Create TGW VPC attachments
resource "aws_ec2_transit_gateway_vpc_attachment" "inspection" {
  subnet_ids         = [var.inspection_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id            = var.inspection_vpc_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    {
      Name = "${var.name_prefix}-inspection-attachment"
    },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  subnet_ids         = [var.spoke_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id            = var.spoke_vpc_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    {
      Name = "${var.name_prefix}-spoke-attachment"
    },
    var.tags
  )
}

# Associate attachments with route tables
resource "aws_ec2_transit_gateway_route_table_association" "inspection" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

# Create routes in TGW route tables
resource "aws_ec2_transit_gateway_route" "spoke_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

resource "aws_ec2_transit_gateway_route" "inspection_to_spoke" {
  destination_cidr_block         = var.spoke_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

