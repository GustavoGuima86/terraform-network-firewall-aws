provider "aws" {
  region = var.aws_region
}

# --- Local Variables for Subnet Calculation, Rules, and Routing ---
locals {
  # --- Subnet Calculations ---
  inspection_vpc_public_subnets     = [for i, az in var.availability_zones : cidrsubnet(var.inspection_vpc_cidr, 8, i * 4 + 0)]
  inspection_vpc_private_subnets    = [for i, az in var.availability_zones : cidrsubnet(var.inspection_vpc_cidr, 8, i * 4 + 1)]
  inspection_vpc_attachment_subnets = [for i, az in var.availability_zones : cidrsubnet(var.inspection_vpc_cidr, 8, i * 4 + 2)]
  inspection_vpc_firewall_subnets   = [for i, az in var.availability_zones : cidrsubnet(var.inspection_vpc_cidr, 8, i * 4 + 3)] # New firewall subnets

  spoke_vpc_subnets = { for k, v in var.spoke_vpcs : k => {
    private    = [for i, az in var.availability_zones : cidrsubnet(v.cidr_block, 8, i * 2 + 0)]
    attachment = [for i, az in var.availability_zones : cidrsubnet(v.cidr_block, 8, i * 2 + 1)]
  } }

  # --- Stateful Firewall Rules ---
  stateful_rules = [
    "pass tls $HOME_NET any -> any any (tls.sni; content:\".github.com\"; endswith; msg:\"Allowing GitHub access\"; sid:1;)",
    "pass tls $HOME_NET any -> any any (tls.sni; content:\".amazonlinux.com\"; endswith; msg:\"Allowing Amazon Linux repository access\"; sid:2;)",
    "pass ip $HOME_NET any -> 8.8.8.8 any (msg:\"Allowing Google DNS\"; sid:3;)"
  ]

  # --- Flattened Data for Routing (Fixes for_each errors) ---
  # Create a flat list of all private route tables in all spoke VPCs
  spoke_private_routes = flatten([
    for spoke_name, vpc in module.spoke_vpcs :
    [for i, rt_id in vpc.private_route_table_ids : {
      key   = "${spoke_name}-priv-rt-${i}"
      rt_id = rt_id
    }]
  ])

  # Create a flat list for routes from public subnets back to all spoke VPCs
  inspection_public_to_spoke_routes = flatten([
    for i, rt_id in module.inspection_vpc.public_route_table_ids :
    [for cidr_name, cidr_details in var.spoke_vpcs : {
      key   = "${i}-${cidr_name}"
      rt_id = rt_id
      cidr  = cidr_details.cidr_block
    }]
  ])
}

# --- VPC Modules ---
module "inspection_vpc" {
  source = "../modules/vpc"

  vpc_name                  = "${var.project_prefix}-inspection"
  vpc_cidr                  = var.inspection_vpc_cidr
  availability_zones        = var.availability_zones
  public_subnet_cidrs       = local.inspection_vpc_public_subnets
  private_subnet_cidrs      = local.inspection_vpc_private_subnets
  attachment_subnet_cidrs   = local.inspection_vpc_attachment_subnets
  firewall_subnet_cidrs     = local.inspection_vpc_firewall_subnets # Pass firewall subnets

  create_igw                = true
  create_nat_gateway        = true
  enable_flow_log           = true

  tags = var.tags
}

module "spoke_vpcs" {
  source   = "../modules/vpc"
  for_each = var.spoke_vpcs

  vpc_name                  = "${var.project_prefix}-${each.key}"
  vpc_cidr                  = each.value.cidr_block
  availability_zones        = var.availability_zones
  private_subnet_cidrs      = local.spoke_vpc_subnets[each.key].private
  attachment_subnet_cidrs   = local.spoke_vpc_subnets[each.key].attachment

  tags = var.tags
}

# --- Core Networking Modules ---
module "transit_gateway" {
  source = "../modules/transit_gateway"

  name_prefix             = var.project_prefix
  inspection_vpc_id       = module.inspection_vpc.vpc_id
  inspection_subnet_ids   = module.inspection_vpc.attachment_subnet_ids

  spoke_vpcs = [for name, vpc in module.spoke_vpcs : {
    name       = name
    vpc_id     = vpc.vpc_id
    subnet_ids = vpc.attachment_subnet_ids
  }]

  tags = var.tags

  depends_on = [module.inspection_vpc, module.spoke_vpcs]
}

module "network_firewall" {
  source = "../modules/network_firewall"

  name_prefix    = var.project_prefix
  vpc_id         = module.inspection_vpc.vpc_id
  subnet_ids     = module.inspection_vpc.firewall_subnet_ids # Use dedicated firewall subnets
  stateful_rules = local.stateful_rules

  tags = var.tags

  depends_on = [module.inspection_vpc]
}
