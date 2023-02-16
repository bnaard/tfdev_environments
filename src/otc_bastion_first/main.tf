# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url    = var.identity_endpoint
}

# Create VPC for setup

resource opentelekomcloud_vpc_v1 vpc_1 {
  name = var.vpc_name
  cidr = var.vpc_cidr

  tags = {
    deployment            = var.deployment_name
    environment           = var.environment
    function              = "vpc"
  }

}

# resource "opentelekomcloud_networking_network_v2" "network_1" {
#   name           = "network_1"
#   admin_state_up = "true"
# }






# public subnet for bastion host

resource "opentelekomcloud_vpc_subnet_v1" "bastion_public_subnet" {
  name       = "bastion_public_subnet"
  vpc_id     = opentelekomcloud_vpc_v1.vpc_1.id
  cidr       = var.bastion_subnet_cidr
  gateway_ip = cidrhost(var.bastion_subnet_cidr, 1) #  "192.168.1.1"

  tags = {
    deployment            = var.deployment_name
    environment           = var.environment
    function              = "bastion"
  }

}

data "opentelekomcloud_images_image_v2" "bastion_image" {
  name = var.bastion_image_name
}

# Create a bastion host

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name              = format("%s_bastion", var.environment)
  image_name        = var.bastion_image_name # data.opentelekomcloud_images_image_v2.bastion_image.id
  flavor_id         = var.bastion_flavor_name   # data.opentelekomcloud_compute_flavor_v2.bastion_flavor.id
  # key_pair          = var.bastion_admin_key_name
  availability_zone = var.bastion_availability_zone
  security_groups   = [opentelekomcloud_networking_secgroup_v2.bastion_securitygroup.name]

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.bastion_public_subnet.id
  }

  block_device {
    uuid                  = data.opentelekomcloud_images_image_v2.bastion_image.id
    source_type           = "image"
    volume_size           = var.bastion_system_disk_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
    volume_type           = "SSD"
  }

  tags = {
    deployment            = var.deployment_name
    environment           = var.environment
    function              = "bastion"
  }
}

# System Disk for bastion host

# resource "opentelekomcloud_evs_volume_v3" "bastion_volume_1" {
#   name              = "bastion_volume_1"
#   description       = "Bastion host system disk"
#   availability_zone = var.bastion_availability_zone
#   volume_type       = "SATA"
#   size              = var.bastion_system_disk_size

#   tags = {
#     workspace = var.environment
#     function  = "BASTION"
#   }
# }

# # Attach system disk to bastion host

# resource "opentelekomcloud_compute_volume_attach_v2" "bastion_volume_attachment" {
#   instance_id = opentelekomcloud_compute_instance_v2.bastion.id
#   volume_id   = opentelekomcloud_evs_volume_v3.bastion_volume_1.id
# }


# SSH key for bastion host

# resource "opentelekomcloud_compute_keypair_v2" "bastion_keypair" {
#   name       = var.bastion_admin_key_name
#   public_key = file(var.bastion_admin_public_key_file)
# }

# Security group for bastion host

resource "opentelekomcloud_networking_secgroup_v2" "bastion_securitygroup" {
  name        = format("%s_bastion_security_group", var.environment)
  description = "Security group for the bastion host"

  tags = {
    deployment            = var.deployment_name
    environment           = var.environment
    function              = "bastion"
  }

}

# SSH ingress allow security group for bastion 

resource "opentelekomcloud_networking_secgroup_rule_v2" "bastion_ssh_ingress_allow_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = var.bastion_ssh_port
  port_range_max    = var.bastion_ssh_port
  remote_ip_prefix  = var.bastion_ssh_access_constraint
  security_group_id = opentelekomcloud_networking_secgroup_v2.bastion_securitygroup.id

  tags = {
    deployment            = var.deployment_name
    environment           = var.environment
    function              = "bastion"
  }

}

# EIP for bastion

resource "opentelekomcloud_vpc_eip_v1" "bastion_public_ip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "bandwidth"
    size        = 8
    share_type  = "PER"
    charge_mode = "traffic"
  }

  tags = {
    deployment            = var.deployment_name
    environment           = var.environment
    function              = "bastion"
  }

}


# # Bind the floating IP to bastion
# resource "opentelekomcloud_networking_floatingip_associate_v2" "floatingip_associate_bastion" {
#   floating_ip = opentelekomcloud_vpc_eip_v1.bastion_public_ip.publicip[0].ip_address
#   instance_id = opentelekomcloud_compute_instance_v2.bastion.id
# }

# resource "opentelekomcloud_networking_floatingip_v2" "bastion_public_ip" {
# }

# # Bind the floating IP to bastion

# resource "opentelekomcloud_networking_floatingip_associate_v2" "bastion_public_ip_association" {
#   floating_ip = opentelekomcloud_networking_floatingip_v2.bastion_public_ip.address
#   instance_id = opentelekomcloud_compute_instance_v2.bastion.id
#   port_id     = opentelekomcloud_compute_instance_v2.bastion_port_1.port_id
# }


# resource "opentelekomcloud_networking_port_v2" "bastion_port_1" {
#   name               = "bastion_port_1"
#   network_id         = opentelekomcloud_networking_network_v2.network_1.id
#   admin_state_up     = "true"
#   security_group_ids = [opentelekomcloud_networking_secgroup_v2.bastion_securitygroup.id]

#   fixed_ip {
#     subnet_id  = opentelekomcloud_networking_subnet_v2.bastion_public_subnet.id
#     ip_address = "192.168.199.10"
#   }
# }
