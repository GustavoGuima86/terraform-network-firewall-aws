output "spoke_vpc_private_subnet_id" {
  description = "ID of the private subnet in the spoke VPC where applications should be deployed"
  value       = module.spoke_vpc.private_subnet_id
}

output "spoke_vpc_id" {
  description = "ID of the spoke VPC"
  value       = module.spoke_vpc.vpc_id
}

output "inspection_vpc_id" {
  description = "ID of the inspection VPC"
  value       = module.inspection_vpc.vpc_id
}

output "network_firewall_arn" {
  description = "ARN of the AWS Network Firewall"
  value       = module.network_firewall.firewall_arn
}

output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway in the inspection VPC"
  value       = module.inspection_vpc.nat_gateway_id
}
