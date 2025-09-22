output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "inspection_attachment_id" {
  description = "ID of the inspection VPC Transit Gateway attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.inspection.id
}

output "spoke_attachments" {
  description = "A map of the spoke VPC Transit Gateway attachments, keyed by spoke VPC name"
  value       = aws_ec2_transit_gateway_vpc_attachment.spoke
}

output "spoke_route_table_id" {
  description = "ID of the shared Transit Gateway route table for all spoke VPCs"
  value       = aws_ec2_transit_gateway_route_table.spoke.id
}

output "inspection_route_table_id" {
  description = "ID of the Transit Gateway route table for the inspection VPC"
  value       = aws_ec2_transit_gateway_route_table.inspection.id
}
