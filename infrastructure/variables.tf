variable "aws_region" {
  description = "AWS region for the deployment"
  type        = string
  default     = "eu-central-1"
}

variable "project_prefix" {
  description = "Prefix for all resource names to ensure uniqueness"
  type        = string
  default     = "tf-net-fw"
}

variable "availability_zones" {
  description = "List of Availability Zones to deploy resources into"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "inspection_vpc_cidr" {
  description = "CIDR block for the Inspection VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "spoke_vpcs" {
  description = "A map of spoke VPC configurations"
  type = map(object({
    cidr_block = string
  }))
  default = {
    "workload-a" = {
      cidr_block = "10.1.0.0/16"
    },
    "workload-b" = {
      cidr_block = "10.2.0.0/16"
    }
  }
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {
    Project   = "Terraform-Network-Firewall"
    ManagedBy = "Terraform"
  }
}
