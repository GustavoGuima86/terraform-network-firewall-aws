# ---------------------------------------------------------------------------------------------------------------------
# Local Variables for AWS Network Firewall Infrastructure
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Subnet CIDR calculations for the inspection VPC
  # Uses a /24 subnet for each type (public, private, attachment, firewall) in each AZ
  inspection_vpc_public_subnets     = [for i, az in var.availability_zones : cidrsubnet(var.inspection_vpc_cidr, 8, i * 4 + 0)]
  inspection_vpc_private_subnets    = [for i, az in var.availability_zones : cidrsubnet(var.inspection_vpc_cidr, 8, i * 4 + 1)]
  inspection_vpc_attachment_subnets = [for i, az in var.availability_zones : cidrsubnet(var.inspection_vpc_cidr, 8, i * 4 + 2)]
  inspection_vpc_firewall_subnets   = [for i, az in var.availability_zones : cidrsubnet(var.inspection_vpc_cidr, 8, i * 4 + 3)]

  # Subnet CIDR calculations for spoke VPCs
  # Uses a /24 subnet for each type (private, attachment) in each AZ
  spoke_vpc_subnets = { for k, v in var.spoke_vpcs : k => {
    private    = [for i, az in var.availability_zones : cidrsubnet(v.cidr_block, 8, i * 2 + 0)]
    attachment = [for i, az in var.availability_zones : cidrsubnet(v.cidr_block, 8, i * 2 + 1)]
  } }

  # Network Firewall stateful rule configuration
  # Defines allowed outbound traffic patterns
  stateful_rules = [
    "pass tls $HOME_NET any -> any any (tls.sni; content:\".github.com\"; endswith; msg:\"Allowing GitHub access\"; sid:1;)",
    "pass tls $HOME_NET any -> any any (tls.sni; content:\".amazonlinux.com\"; endswith; msg:\"Allowing Amazon Linux repository access\"; sid:2;)",
    "pass ip $HOME_NET any -> 8.8.8.8 any (msg:\"Allowing Google DNS\"; sid:3;)"
  ]
}