# ---------------------------------------------------------------------------------------------------------------------
# VPC Module Outputs
# ---------------------------------------------------------------------------------------------------------------------

# VPC Outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "attachment_subnet_ids" {
  description = "List of IDs of Transit Gateway attachment subnets"
  value       = slice(module.vpc.intra_subnets, length(var.firewall_subnet_cidrs), length(module.vpc.intra_subnets))
}

output "firewall_subnet_ids" {
  description = "List of IDs of Network Firewall subnets"
  value       = slice(module.vpc.intra_subnets, 0, length(var.firewall_subnet_cidrs))
}

# Route Table Outputs
output "public_route_table_ids" {
  description = "List of IDs of public subnet route tables"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of IDs of private subnet route tables"
  value       = module.vpc.private_route_table_ids
}

output "intra_route_table_ids" {
  description = "List of IDs of intra subnet route tables (used by firewall and attachment subnets)"
  value       = module.vpc.intra_route_table_ids
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of IDs of NAT Gateways"
  value       = module.vpc.natgw_ids
}

# Internet Gateway Output
output "internet_gateway_id" {
  description = "ID of the Internet Gateway (if created)"
  value       = module.vpc.igw_id
}
