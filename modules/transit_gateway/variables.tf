variable "name_prefix" {
  description = "Name prefix for the Transit Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
