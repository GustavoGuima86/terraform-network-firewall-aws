output "transit_gateway_id" {
  description = "ID of the created Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "inspection_route_table_id" {
  description = "ID of the Transit Gateway route table for inspection VPC"
  value       = aws_ec2_transit_gateway_route_table.inspection.id
}

output "spoke_route_table_id" {
  description = "ID of the Transit Gateway route table for spoke VPCs"
  value       = aws_ec2_transit_gateway_route_table.spoke.id
}
