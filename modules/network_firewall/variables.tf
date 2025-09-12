variable "vpc_id" {
  description = "ID of the inspection VPC"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the firewall endpoint will be placed"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "stateful_rules" {
  description = "List of Suricata-compatible rules for the stateful rule group"
  type        = list(string)
}

variable "private_route_table_id" {
  description = "ID of the private subnet route table"
  type        = string
}

variable "tgw_attachment_route_table_id" {
  description = "ID of the TGW attachment subnet route table"
  type        = string
}

variable "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  type        = string
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
