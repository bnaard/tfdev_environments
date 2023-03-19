# Security group for node

resource "opentelekomcloud_networking_secgroup_v2" "node_securitygroup" {
  name                 = "${var.name}_security_group"
  description          = "Security group for the node ${var.name}"
  delete_default_rules = true
}



# SSH ingress allow security group

resource "opentelekomcloud_networking_secgroup_rule_v2" "ssh_ingress_allow_rule" {
  for_each          = toset(var.trusted_ssh_origins)

  description       = "SSH allowed origins from Internet"
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = length(split("/", each.value)) == 2 ? each.value : "${each.value}/32"
  security_group_id = opentelekomcloud_networking_secgroup_v2.node_securitygroup.id
}


resource "opentelekomcloud_networking_secgroup_rule_v2" "ssh_egress_allow_rule" {
  description       = "Allow all outgoing communication from the node ${var.name} to internet."
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = opentelekomcloud_networking_secgroup_v2.node_securitygroup.id
}
