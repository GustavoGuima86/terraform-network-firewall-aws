output "firewall_id" {
  description = "The ID of the Network Firewall"
  value       = aws_networkfirewall_firewall.main.id
}

output "firewall_arn" {
  description = "The ARN of the Network Firewall"
  value       = aws_networkfirewall_firewall.main.arn
}

output "firewall_endpoint_id" {
  description = "The ID of the Network Firewall endpoint"
  value       = data.aws_networkfirewall_firewall.main.firewall_status[0].sync_states[0].endpoint_id
}

output "firewall_policy_arn" {
  description = "The ARN of the Network Firewall policy"
  value       = aws_networkfirewall_firewall_policy.main.arn
}
