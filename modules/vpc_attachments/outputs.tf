# ---------------------------------------------------------------------------------------------------------------------
# VPC Attachments Module Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "inspection_attachment_id" {
  description = "ID of the inspection VPC Transit Gateway attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment.inspection.id
}

output "spoke_attachment_ids" {
  description = "Map of spoke VPC Transit Gateway attachment IDs"
  value       = { for k, v in aws_ec2_transit_gateway_vpc_attachment.spoke : k => v.id }
}
