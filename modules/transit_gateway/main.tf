# Create the Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description = "${var.name_prefix}-tgw"

  # Disable default behaviors for explicit control
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"

  tags = merge(
    {
      Name = "${var.name_prefix}-tgw"
    },
    var.tags
  )
}

# --- TGW Route Tables ---
# Route table for traffic coming from the inspection VPC
resource "aws_ec2_transit_gateway_route_table" "inspection" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    {
      Name = "${var.name_prefix}-inspection-rt"
    },
    var.tags
  )
}

# Route table for all spoke VPCs
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    {
      Name = "${var.name_prefix}-spoke-rt"
    },
    var.tags
  )
}

# --- TGW Attachments ---
# Attachment for the inspection VPC (multi-AZ)
resource "aws_ec2_transit_gateway_vpc_attachment" "inspection" {
  subnet_ids         = var.inspection_subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = var.inspection_vpc_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    {
      Name = "${var.name_prefix}-inspection-attachment"
    },
    var.tags
  )
}

# Attachments for each spoke VPC (multi-AZ)
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke" {
  for_each = { for vpc in var.spoke_vpcs : vpc.name => vpc }

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = each.value.vpc_id

  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags = merge(
    {
      Name = "${var.name_prefix}-${each.key}-attachment"
    },
    var.tags
  )
}

# --- TGW Associations and Propagations ---
# Associate inspection attachment with its route table
resource "aws_ec2_transit_gateway_route_table_association" "inspection" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

# Associate all spoke attachments with the shared spoke route table
resource "aws_ec2_transit_gateway_route_table_association" "spoke" {
  for_each = aws_ec2_transit_gateway_vpc_attachment.spoke

  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}

# Propagate routes from spoke attachments to the inspection route table
resource "aws_ec2_transit_gateway_route_table_propagation" "from_spoke_to_inspection" {
  for_each = aws_ec2_transit_gateway_vpc_attachment.spoke

  transit_gateway_attachment_id  = each.value.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

# --- TGW Routes ---
# In the spoke route table, create a default route to the inspection VPC attachment
resource "aws_ec2_transit_gateway_route" "spoke_to_inspection" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke.id
}
