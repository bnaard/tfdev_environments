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

data "opentelekomcloud_compute_flavor_v2" "bastion_flavor" {
  name = var.bastion_flavor_name
}


locals {
  cloud_init_files = flatten([
    for path_to_cloud_init in var.bastion_paths_to_cloud_init_files : [
      for path in fileset("", "${path_to_cloud_init}/*.{yml,yaml}") : path
    ]
  ])

  cloud_init_emergency_user_config = !var.bastion_emergency_user ? "" : <<EOT
users:
  - default
  - name: ${var.bastion_emergency_user_spec.username}
    groups: ${var.bastion_emergency_user_spec.groups}
    shell: ${var.bastion_emergency_user_spec.shell}
    ssh-authorized-keys:
      - ${file(var.bastion_emergency_user_spec.public_key_file)}
  EOT
}

    # sudo: ['ALL=(ALL) NOPASSWD:ALL']


output "cloudfiles" {
  value = join( 
        "\n", 
        concat(["#cloud-config"], [for filepath in local.cloud_init_files : file(filepath)], [local.cloud_init_emergency_user_config] )
      )
}



# Create a bastion host

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name              = format("%s_bastion", var.environment)
  image_name        = data.opentelekomcloud_images_image_v2.bastion_image.id
  flavor_id         = data.opentelekomcloud_compute_flavor_v2.bastion_flavor.id
  availability_zone = var.bastion_availability_zone
  security_groups   = [opentelekomcloud_networking_secgroup_v2.bastion_securitygroup.name]

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.bastion_public_subnet.id
  }

  user_data = base64encode(
    sensitive(
      join( 
        "\n", 
        concat(["#cloud-config"], [for filepath in local.cloud_init_files : file(filepath)], [local.cloud_init_emergency_user_config] )
      )
    )
  )

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

# SSH key for bastion host

# resource "opentelekomcloud_compute_keypair_v2" "bastion_keypair" {
#   name       = var.bastion_admin_key_name
#   public_key = file(var.bastion_admin_public_key_file)
# }

# Security group for bastion host

resource "opentelekomcloud_networking_secgroup_v2" "bastion_securitygroup" {
  name        = format("%s_bastion_security_group", var.environment)
  description = "Security group for the bastion host"
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

# Bind the floating IP to bastion

resource "opentelekomcloud_networking_floatingip_associate_v2" "floatingip_associate_bastion" {
  floating_ip = opentelekomcloud_vpc_eip_v1.bastion_public_ip.publicip.0.ip_address
  port_id     = opentelekomcloud_compute_instance_v2.bastion.network.0.port
}
