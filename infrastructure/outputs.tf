output "inspection_vpc" {
  description = "Outputs from the inspection VPC"
  value = {
    vpc_id   = module.inspection_vpc.vpc_id
    vpc_cidr = module.inspection_vpc.vpc_cidr_block
  }
}

output "spoke_vpcs" {
  description = "Outputs from the spoke VPCs, keyed by name"
  value = { for name, vpc in module.spoke_vpcs : name => {
    vpc_id   = vpc.vpc_id
    vpc_cidr = vpc.vpc_cidr_block
  } }
}

output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = module.transit_gateway.transit_gateway_id
}

output "network_firewall_arn" {
  description = "The ARN of the AWS Network Firewall"
  value       = module.network_firewall.firewall_arn
}
