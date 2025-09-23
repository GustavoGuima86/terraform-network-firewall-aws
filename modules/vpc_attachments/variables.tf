# ---------------------------------------------------------------------------------------------------------------------
# Required Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "transit_gateway_id" {
  description = "ID of the Transit Gateway to attach VPCs to"
  type        = string
}

variable "inspection_vpc_id" {
  description = "ID of the inspection VPC"
  type        = string
}

variable "inspection_subnet_ids" {
  description = "List of subnet IDs in the inspection VPC for TGW attachment"
  type        = list(string)
}

variable "inspection_route_table_id" {
  description = "ID of the Transit Gateway route table for inspection VPC"
  type        = string
}

variable "spoke_route_table_id" {
  description = "ID of the Transit Gateway route table for spoke VPCs"
  type        = string
}

variable "spoke_vpcs" {
  description = "List of spoke VPCs to attach to the Transit Gateway"
  type = list(object({
    name       = string
    vpc_id     = string
    subnet_ids = list(string)
  }))
}

# ---------------------------------------------------------------------------------------------------------------------
# Optional Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
  default     = "tgw"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
