###
#
# opentelekomcloud-bastion
#

## SSH key

resource "opentelekomcloud_compute_keypair_v2" "bastion-keypair" {
  name       = var.key_name
  public_key = file(var.key_file)
}

# Security group for the bastion

resource "opentelekomcloud_networking_secgroup_v2" "nc_ssh_bastion_sg" {
  name        = format("%s_ssh_sg", var.stage)
  description = "SSH Access to the bastion"
}

# Security group rule for the bastion

resource "opentelekomcloud_networking_secgroup_rule_v2" "nc_ssh_bastion_sg_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.ssh_port
  port_range_max    = var.ssh_port
  remote_ip_prefix  = var.access_constraint
  security_group_id = opentelekomcloud_networking_secgroup_v2.nc_ssh_bastion_sg.id
}

# Bastion server image

data "opentelekomcloud_images_image_v2" "bastion_image" {
  name = var.image_name
}

# Bastion server flavor

data "opentelekomcloud_compute_flavor_v2" "bastion_flavor" {
  vcpus = var.vcpus
  ram   = var.ram
}

# Bastion server VM

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name            = format("%s_bastion", var.stage)
  image_id        = data.opentelekomcloud_images_image_v2.bastion_image.id
  flavor_id       = data.opentelekomcloud_compute_flavor_v2.bastion_flavor.id
  key_pair        = var.key_name
  security_groups = ["default", opentelekomcloud_networking_secgroup_v2.nc_ssh_bastion_sg.name]
  network {
    uuid = var.public_subnet_id
  }

  tags = {
    workspace = var.stage
    function  = "BASTION"
  }

  user_data = templatefile(
    var.init_script,
    {
      admin_user = var.ssh_user_name
      ssh_key    = file(var.key_file)
    }
  )
}

## EIP for bastion

resource "opentelekomcloud_networking_floatingip_v2" "bastion_public_ip" {
}

## Bind the floating IP to bastion

resource "opentelekomcloud_networking_floatingip_associate_v2" "bastion_associate" {
  floating_ip = opentelekomcloud_networking_floatingip_v2.bastion_public_ip.address
  port_id     = opentelekomcloud_compute_instance_v2.bastion.network.0.port
}