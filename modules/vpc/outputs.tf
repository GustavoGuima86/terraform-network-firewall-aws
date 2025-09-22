output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "attachment_subnet_ids" {
  description = "The IDs of the attachment subnets"
  value       = aws_subnet.attachment[*].id
}

output "firewall_subnet_ids" {
  description = "The IDs of the firewall subnets"
  value       = aws_subnet.firewall[*].id
}

output "public_route_table_ids" {
  description = "The IDs of the public subnet route tables"
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "The IDs of the private subnet route tables"
  value       = aws_route_table.private[*].id
}

output "attachment_route_table_ids" {
  description = "The IDs of the attachment subnet route tables"
  value       = aws_route_table.attachment[*].id
}

output "firewall_route_table_ids" {
  description = "The IDs of the firewall subnet route tables"
  value       = aws_route_table.firewall[*].id
}

output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = aws_nat_gateway.main[*].id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}
