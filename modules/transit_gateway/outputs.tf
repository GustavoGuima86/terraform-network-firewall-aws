output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "transit_gateway_spoke_attachment_id" {
  description = "ID of the spoke VPC Transit Gateway attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.spoke.id
}

output "transit_gateway_inspection_attachment_id" {
  description = "ID of the inspection VPC Transit Gateway attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.inspection.id
}

output "transit_gateway_spoke_route_table_id" {
  description = "ID of the spoke VPC Transit Gateway route table"
  value       = aws_ec2_transit_gateway_route_table.spoke.id
}

output "transit_gateway_inspection_route_table_id" {
  description = "ID of the inspection VPC Transit Gateway route table"
  value       = aws_ec2_transit_gateway_route_table.inspection.id
}
