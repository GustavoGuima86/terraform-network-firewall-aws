aws_region       = "us-west-2"
availability_zone = "us-west-2a"
project_prefix   = "egress-fw"

inspection_vpc_cidr = "10.0.0.0/16"
spoke_vpc_cidr      = "10.1.0.0/16"

tags = {
  Environment = "production"
  Terraform   = "true"
  Project     = "centralized-egress"
}
