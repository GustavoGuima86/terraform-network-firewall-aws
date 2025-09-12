provider "aws" {
  region = var.aws_region
}

locals {
  inspection_vpc_subnets = {
    public     = cidrsubnet(var.inspection_vpc_cidr, 8, 0)      # 10.0.0.0/24
    private    = cidrsubnet(var.inspection_vpc_cidr, 8, 1)      # 10.0.1.0/24
    attachment = cidrsubnet(var.inspection_vpc_cidr, 8, 2)      # 10.0.2.0/24
  }

  spoke_vpc_subnets = {
    public     = cidrsubnet(var.spoke_vpc_cidr, 8, 0)          # 10.1.0.0/24
    private    = cidrsubnet(var.spoke_vpc_cidr, 8, 1)          # 10.1.1.0/24
    attachment = cidrsubnet(var.spoke_vpc_cidr, 8, 2)          # 10.1.2.0/24
  }

  # Example Suricata rules for egress filtering
  stateful_rules = [
    "pass tls $HOME_NET any -> any any (tls.sni; content:\".github.com\"; endswith; msg:\"Allowing GitHub access\"; sid:1;)",
    "pass tls $HOME_NET any -> any any (tls.sni; content:\".amazonlinux.com\"; endswith; msg:\"Allowing Amazon Linux repository access\"; sid:2;)",
    "pass ip $HOME_NET any -> 8.8.8.8 any (msg:\"Allowing Google DNS\"; sid:3;)",
    "drop ip $HOME_NET any -> any any (msg:\"Default deny\"; sid:4;)"
  ]
}

# Create the inspection VPC
module "inspection_vpc" {
  source = "../modules/vpc"

  vpc_cidr              = var.inspection_vpc_cidr
  vpc_name             = "${var.project_prefix}-inspection"
  availability_zone    = var.availability_zone
  public_subnet_cidr   = local.inspection_vpc_subnets.public
  private_subnet_cidr  = local.inspection_vpc_subnets.private
  attachment_subnet_cidr = local.inspection_vpc_subnets.attachment
  create_igw          = true
  create_nat_gateway  = true
  tags                = var.tags
}

# Create the spoke VPC
module "spoke_vpc" {
  source = "../modules/vpc"

  vpc_cidr              = var.spoke_vpc_cidr
  vpc_name             = "${var.project_prefix}-spoke"
  availability_zone    = var.availability_zone
  public_subnet_cidr   = local.spoke_vpc_subnets.public
  private_subnet_cidr  = local.spoke_vpc_subnets.private
  attachment_subnet_cidr = local.spoke_vpc_subnets.attachment
  create_igw          = false
  create_nat_gateway  = false
  tags                = var.tags
}

# Create the Transit Gateway and attachments
module "transit_gateway" {
  source = "../modules/transit_gateway"

  name_prefix          = var.project_prefix
  inspection_vpc_id    = module.inspection_vpc.vpc_id
  spoke_vpc_id        = module.spoke_vpc.vpc_id
  inspection_subnet_id = module.inspection_vpc.attachment_subnet_id
  spoke_subnet_id     = module.spoke_vpc.attachment_subnet_id
  inspection_vpc_cidr = var.inspection_vpc_cidr
  spoke_vpc_cidr      = var.spoke_vpc_cidr
  tags                = var.tags

  depends_on = [
    module.inspection_vpc,
    module.spoke_vpc
  ]
}

# Create the Network Firewall
module "network_firewall" {
  source = "../modules/network_firewall"

  name_prefix               = var.project_prefix
  vpc_id                   = module.inspection_vpc.vpc_id
  subnet_id                = module.inspection_vpc.attachment_subnet_id
  stateful_rules           = local.stateful_rules
  private_route_table_id   = module.inspection_vpc.private_route_table_id
  tgw_attachment_route_table_id = module.inspection_vpc.attachment_route_table_id
  nat_gateway_id           = module.inspection_vpc.nat_gateway_id
  tags                     = var.tags

  depends_on = [
    module.inspection_vpc,
    module.transit_gateway
  ]
}

# Add route to TGW in spoke VPC's private subnet
resource "aws_route" "spoke_to_tgw" {
  route_table_id         = module.spoke_vpc.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.transit_gateway.transit_gateway_id

  depends_on = [
    module.transit_gateway
  ]
}
