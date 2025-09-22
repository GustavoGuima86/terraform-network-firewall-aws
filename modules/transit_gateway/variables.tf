variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "inspection_vpc_id" {
  description = "ID of the inspection VPC"
  type        = string
}

variable "inspection_subnet_ids" {
  description = "A list of subnet IDs in the inspection VPC for TGW attachments"
  type        = list(string)
}

variable "spoke_vpcs" {
  description = "A list of spoke VPC configurations to attach to the Transit Gateway"
  type = list(object({
    name       = string
    vpc_id     = string
    subnet_ids = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
