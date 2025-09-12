output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "The ID of the private subnet"
  value       = aws_subnet.private.id
}

output "attachment_subnet_id" {
  description = "The ID of the attachment subnet"
  value       = aws_subnet.attachment.id
}

output "private_route_table_id" {
  description = "The ID of the private subnet route table"
  value       = aws_route_table.private.id
}

output "attachment_route_table_id" {
  description = "The ID of the attachment subnet route table"
  value       = aws_route_table.attachment.id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway (if created)"
  value       = var.create_nat_gateway ? aws_nat_gateway.main[0].id : null
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}
