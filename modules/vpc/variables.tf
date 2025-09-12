variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "availability_zone" {
  description = "Availability Zone for the subnets"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
}

variable "attachment_subnet_cidr" {
  description = "CIDR block for the TGW/Firewall attachment subnet"
  type        = string
}

variable "create_igw" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = false
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
