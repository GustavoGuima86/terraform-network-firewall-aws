variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "availability_zones" {
  description = "A list of Availability Zones for the subnets"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "A list of CIDR blocks for the private subnets"
  type        = list(string)
  default     = []
}

variable "attachment_subnet_cidrs" {
  description = "A list of CIDR blocks for the TGW/Firewall attachment subnets"
  type        = list(string)
  default     = []
}

variable "firewall_subnet_cidrs" {
  description = "A list of CIDR blocks for the firewall subnets"
  type        = list(string)
  default     = []
}

variable "create_igw" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = false
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway for each public subnet"
  type        = bool
  default     = false
}

variable "enable_flow_log" {
  description = "Whether to enable VPC Flow Logs to a module-managed CloudWatch Log Group."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
