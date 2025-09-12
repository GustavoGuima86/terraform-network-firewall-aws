variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "inspection_vpc_id" {
  description = "ID of the inspection VPC"
  type        = string
}

variable "spoke_vpc_id" {
  description = "ID of the spoke VPC"
  type        = string
}

variable "inspection_subnet_id" {
  description = "ID of the subnet in the inspection VPC for TGW attachment"
  type        = string
}

variable "spoke_subnet_id" {
  description = "ID of the subnet in the spoke VPC for TGW attachment"
  type        = string
}

variable "inspection_vpc_cidr" {
  description = "CIDR block of the inspection VPC"
  type        = string
}

variable "spoke_vpc_cidr" {
  description = "CIDR block of the spoke VPC"
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
