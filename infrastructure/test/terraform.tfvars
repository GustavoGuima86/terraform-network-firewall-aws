aws_region = "eu-central-1"

project_prefix = "tf-net-fw"

availability_zones = ["eu-central-1a", "eu-central-1b"]

inspection_vpc_cidr = "10.0.0.0/16"

spoke_vpcs = {
  "workload-a" = {
    cidr_block = "10.1.0.0/16"
  },
  "workload-b" = {
    cidr_block = "10.2.0.0/16"
  }
}

tags = {
  Project   = "Terraform-Network-Firewall"
  ManagedBy = "Terraform"
}
