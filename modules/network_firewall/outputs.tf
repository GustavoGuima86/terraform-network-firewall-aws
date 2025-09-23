# ---------------------------------------------------------------------------------------------------------------------
# Network Firewall Module Outputs
# ---------------------------------------------------------------------------------------------------------------------

output "firewall_arn" {
  description = "ARN of the Network Firewall"
  value       = aws_networkfirewall_firewall.main.arn
}

output "firewall_id" {
  description = "ID of the Network Firewall"
  value       = aws_networkfirewall_firewall.main.id
}

output "firewall_endpoints" {
  description = "Map of Network Firewall endpoints per AZ"
  value       = {
    for ep in aws_networkfirewall_firewall.main.firewall_status[0].sync_states :
    ep.availability_zone => ep.attachment[0].endpoint_id
  }
}

output "sync_states" {
  description = "Synchronization states for the Network Firewall endpoints"
  value       = try(aws_networkfirewall_firewall.main.firewall_status[0].sync_states[*].attachment[0].status_message, null)
}
