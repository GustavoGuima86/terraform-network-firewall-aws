# --- Spoke VPC Routing ---
# For each private subnet in each spoke VPC, add a default route to the Transit Gateway.
resource "aws_route" "spoke_private_to_tgw" {
  for_each = { for route in local.spoke_private_routes : route.key => route }

  route_table_id         = each.value.rt_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}

# --- Inspection VPC Routing ---

# Route 1: TGW Attachment Subnet -> Firewall Endpoint
# For traffic arriving from the TGW, send it to the firewall endpoint in the same AZ.
resource "aws_route" "inspection_tgw_to_firewall" {
  for_each = { for i, az in var.availability_zones : az => {
    rt_id    = module.inspection_vpc.attachment_route_table_ids[i]
    fw_ep_id = module.network_firewall.firewall_endpoints[az]
  } }

  route_table_id         = each.value.rt_id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = each.value.fw_ep_id
}

# Route 2: Firewall Subnet -> NAT Gateway (for Egress)
# For traffic leaving the firewall, send internet-bound traffic to the NAT Gateway in the same AZ.
resource "aws_route" "inspection_firewall_to_nat" {
  for_each = { for i, az in var.availability_zones : az => {
    rt_id  = module.inspection_vpc.firewall_route_table_ids[i]
    nat_id = module.inspection_vpc.nat_gateway_ids[i]
  } }

  route_table_id         = each.value.rt_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = each.value.nat_id
}

# Route 3: Public Subnet (hosting NAT GW) -> TGW (for Return Traffic)
# For return traffic from the internet, if it's destined for a spoke, send it back to the TGW.
resource "aws_route" "inspection_public_to_tgw" {
  for_each = { for route in local.inspection_public_to_spoke_routes : route.key => route }

  route_table_id         = each.value.rt_id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = module.transit_gateway.transit_gateway_id
}
