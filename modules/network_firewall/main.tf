# ---------------------------------------------------------------------------------------------------------------------
# Firewall Rule Groups
# ---------------------------------------------------------------------------------------------------------------------

# Stateful rule group for egress filtering
resource "aws_networkfirewall_rule_group" "stateful_egress" {
  capacity = 100
  name     = "${var.name_prefix}-stateful-egress"
  type     = "STATEFUL"

  rule_group {
    rules_source {
      rules_string = join("\n", var.stateful_rules)
    }

    stateful_rule_options {
      rule_order = "STRICT_ORDER"
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

# ---------------------------------------------------------------------------------------------------------------------
# Firewall Policy Configuration
# ---------------------------------------------------------------------------------------------------------------------

# Introduce a delay to work around an AWS API race condition
# This ensures the rule group is fully propagated before the policy is created
resource "time_sleep" "wait_for_rule_group" {
  create_duration = "30s"
  depends_on     = [aws_networkfirewall_rule_group.stateful_egress]
}

# Firewall policy that uses the stateful rule group
resource "aws_networkfirewall_firewall_policy" "main" {
  name = "${var.name_prefix}-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateful_engine_options {
      rule_order = "STRICT_ORDER"
    }

    stateful_rule_group_reference {
      priority     = 1
      resource_arn = aws_networkfirewall_rule_group.stateful_egress.arn
    }

    stateful_default_actions = ["aws:drop_strict"]
  }

  tags = var.tags

  # Depend on the sleep timer instead of directly on the rule group
  depends_on = [time_sleep.wait_for_rule_group]
}

# ---------------------------------------------------------------------------------------------------------------------
# AWS Network Firewall
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_networkfirewall_firewall" "main" {
  name                = "${var.name_prefix}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = var.vpc_id

  dynamic "subnet_mapping" {
    for_each = toset(var.subnet_ids)
    content {
      subnet_id = subnet_mapping.value
    }
  }

  tags = var.tags
}
