# Stateful rule group for egress filtering
resource "aws_networkfirewall_rule_group" "stateful_egress" {
  capacity = 100
  name     = "${var.name_prefix}-stateful-egress"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      rules_string = join("\n", var.stateful_rules)
    }
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
        }
      }
    }
  }

  tags = var.tags
}

# Firewall policy that uses the rule group
resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.name_prefix}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.stateful_egress.arn
    }

    stateful_default_actions = ["aws:drop_strict"]
  }

  tags = var.tags
}

# Network Firewall
resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.name_prefix}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = var.vpc_id

  subnet_mapping {
    subnet_id = var.subnet_id
  }

  tags = var.tags
}

# Data source to get the firewall's endpoints
data "aws_networkfirewall_firewall" "main" {
  name = aws_networkfirewall_firewall.main.name

  depends_on = [aws_networkfirewall_firewall.main]
}

# Route from TGW attachment to firewall
resource "aws_route" "to_firewall" {
  route_table_id         = var.tgw_attachment_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id       = data.aws_networkfirewall_firewall.main.firewall_status[0].sync_states[0].endpoint_id
}

# Route from firewall to NAT Gateway
resource "aws_route" "to_nat" {
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_gateway_id
}
