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
# Create the Transit Gateway
module "transit_gateway" {
  source = "../modules/transit_gateway"

  name_prefix = var.project_prefix
  tags       = var.tags
}

# Handle VPC attachments to the Transit Gateway
module "vpc_attachments" {
  source = "../modules/vpc_attachments"

  name_prefix              = var.project_prefix
  transit_gateway_id       = module.transit_gateway.transit_gateway_id
  inspection_vpc_id        = module.inspection_vpc.vpc_id
  inspection_subnet_ids    = module.inspection_vpc.attachment_subnet_ids
  inspection_route_table_id = module.transit_gateway.inspection_route_table_id
  spoke_route_table_id     = module.transit_gateway.spoke_route_table_id

  spoke_vpcs = [for name, vpc in module.spoke_vpcs : {
    name       = name
    vpc_id     = vpc.vpc_id
    subnet_ids = vpc.attachment_subnet_ids
  }]

  tags = var.tags

  depends_on = [module.transit_gateway, module.inspection_vpc, module.spoke_vpcs]
}

# Network Firewall Module
module "network_firewall" {
  source = "../modules/network_firewall"

  name_prefix    = var.project_prefix
  vpc_id         = module.inspection_vpc.vpc_id
  subnet_ids     = module.inspection_vpc.firewall_subnet_ids
  stateful_rules = local.stateful_rules
  tags           = var.tags

  depends_on = [module.inspection_vpc]
}
