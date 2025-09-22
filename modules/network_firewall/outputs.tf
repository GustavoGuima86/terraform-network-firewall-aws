output "firewall_arn" {
  description = "The ARN of the Network Firewall"
  value       = aws_networkfirewall_firewall.main.arn
}

output "firewall_endpoints" {
  description = "A map of firewall endpoint IDs, keyed by Availability Zone."
  value = {
    for state in aws_networkfirewall_firewall.main.firewall_status[0].sync_states :
    state.availability_zone => state.endpoint_id
  }
}
