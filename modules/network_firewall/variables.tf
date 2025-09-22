variable "vpc_id" {
  description = "ID of the inspection VPC where the firewall will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs where the firewall endpoints will be placed (one per AZ)"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "stateful_rules" {
  description = "List of Suricata-compatible rules for the stateful rule group"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
