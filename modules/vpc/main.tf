# ---------------------------------------------------------------------------------------------------------------------
# AWS VPC Module
# Uses AWS VPC Terraform module to create a VPC with customizable subnets and routing
# ---------------------------------------------------------------------------------------------------------------------

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 6.0.1"

  # ---------------------------------------------------------------------------------------------------------------------
  # VPC Configuration
  # ---------------------------------------------------------------------------------------------------------------------
  name = var.vpc_name
  cidr = var.vpc_cidr

  # Subnet Configuration
  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs
  # Combine firewall and attachment subnets as intra subnets (no internet access)
  intra_subnets   = concat(var.firewall_subnet_cidrs, var.attachment_subnet_cidrs)

  # ---------------------------------------------------------------------------------------------------------------------
  # Network Features
  # ---------------------------------------------------------------------------------------------------------------------

  # NAT Gateway - One per AZ for high availability if enabled
  enable_nat_gateway     = var.create_nat_gateway
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  # Internet Gateway - Optional based on VPC type
  create_igw = var.create_igw

  # DNS Settings
  enable_dns_hostnames = true
  enable_dns_support   = true

  # ---------------------------------------------------------------------------------------------------------------------
  # Resource Tagging
  # ---------------------------------------------------------------------------------------------------------------------

  # Route Table Tags
  private_route_table_tags = {
    Name = "${var.vpc_name}-private-rt"
  }
  public_route_table_tags = {
    Name = "${var.vpc_name}-public-rt"
  }
  intra_route_table_tags = {
    Name = "${var.vpc_name}-intra-rt"
  }

  # ---------------------------------------------------------------------------------------------------------------------
  # VPC Flow Logs
  # ---------------------------------------------------------------------------------------------------------------------

  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_log_group = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.enable_flow_log
  flow_log_destination_type           = "cloud-watch-logs"
  flow_log_cloudwatch_log_group_name_prefix = "/aws/vpc-flow-logs/${var.vpc_name}"

  tags = var.tags
}
