# ---------------------------------------------------------------------------------------------------------------------
# AWS Transit Gateway Module
# Creates a Transit Gateway with route tables for network segmentation
# ---------------------------------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------------------------------
# Transit Gateway
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway" "main" {
  description = "${var.name_prefix}-tgw"

  # Enable default route table for simplicity
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = merge(
    {
      Name = "${var.name_prefix}-tgw"
    },
    var.tags
  )
}

# ---------------------------------------------------------------------------------------------------------------------
# Transit Gateway Route Tables
# ---------------------------------------------------------------------------------------------------------------------

# Route table for inspection VPC - receives traffic from spoke VPCs
resource "aws_ec2_transit_gateway_route_table" "inspection" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    {
      Name = "${var.name_prefix}-inspection-rt"
    },
    var.tags
  )
}

# Route table for spoke VPCs - sends traffic to inspection VPC
resource "aws_ec2_transit_gateway_route_table" "spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.main.id

  tags = merge(
    {
      Name = "${var.name_prefix}-spoke-rt"
    },
    var.tags
  )
}
