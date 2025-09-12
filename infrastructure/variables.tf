variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the resources"
  type        = string
}

variable "project_prefix" {
  description = "Prefix to be used for all resource names"
  type        = string
  default     = "egress-fw"
}

variable "inspection_vpc_cidr" {
  description = "CIDR block for the inspection VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "spoke_vpc_cidr" {
  description = "CIDR block for the spoke VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {
    Environment = "production"
    Terraform   = "true"
  }
}
