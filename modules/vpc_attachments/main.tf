# ---------------------------------------------------------------------------------------------------------------------
# AWS Transit Gateway VPC Attachments Module
# Manages VPC attachments and route associations for Transit Gateway
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# VPC Attachments
# ---------------------------------------------------------------------------------------------------------------------

# Attachment for the inspection VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "inspection" {
  subnet_ids         = var.inspection_subnet_ids
  transit_gateway_id = var.transit_gateway_id
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

# Attachments for spoke VPCs
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  for_each = { for vpc in var.spoke_vpcs : vpc.name => vpc }

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = var.transit_gateway_id
  vpc_id            = each.value.vpc_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    {
      Name = "${var.name_prefix}-${each.key}-attachment"
    },
    var.tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Route Table Associations
# ---------------------------------------------------------------------------------------------------------------------

# Associate inspection VPC with inspection route table
resource "aws_ec2_transit_gateway_route_table_association" "inspection" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = var.inspection_route_table_id
}

# Associate spoke VPCs with spoke route table
resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  for_each = { for vpc in var.spoke_vpcs : vpc.name => vpc }

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = var.spoke_route_table_id
}

# ---------------------------------------------------------------------------------------------------------------------
# Route Table Propagations
# ---------------------------------------------------------------------------------------------------------------------

# Propagate spoke VPC routes to inspection route table
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_to_inspection" {
  for_each = { for vpc in var.spoke_vpcs : vpc.name => vpc }

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.spoke[each.key].id
  transit_gateway_route_table_id = var.inspection_route_table_id
}

# Default route from spoke VPCs to inspection VPC
resource "aws_ec2_transit_gateway_route" "default_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = var.spoke_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.inspection]
}
