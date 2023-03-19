
data "opentelekomcloud_images_image_v2" "bastion_image" {
  name = var.image_name
}

data "opentelekomcloud_compute_flavor_v2" "bastion_flavor" {
  name = var.flavor_name
}

data "template_file" "security_cloud_config" {
  template = "${file("${path.module}/cloud-init/security.yaml")}"
  vars = {
  }
}

data "template_file" "users_cloud_config" {
  template = !var.emergency_user ? "" : "${file("${path.module}/cloud-init/users.yaml")}"
  vars = {
    username        = var.emergency_user_spec.username
    shell           = var.emergency_user_spec.shell
    groups          = "[ ${join( ", ", var.emergency_user_spec.groups)} ]"
    sudo            = var.emergency_user_spec.sudo
    public_key_file = file(var.emergency_user_spec.public_key_file)
  }
}

data "opentelekomcloud_compute_availability_zones_v2" "available_availability_zones" {}

data "opentelekomcloud_identity_project_v3" "current" {}

locals {
  region            = data.opentelekomcloud_identity_project_v3.current.region
  availability_zone = var.availability_zone == "" ? "${local.region}-01" : var.availability_zone
}



# Create a bastion host

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name              = var.name
  image_name        = data.opentelekomcloud_images_image_v2.bastion_image.id
  flavor_id         = data.opentelekomcloud_compute_flavor_v2.bastion_flavor.id
  availability_zone = local.availability_zone
  security_groups   = [opentelekomcloud_networking_secgroup_v2.bastion_securitygroup.name]

  network {
    uuid = var.subnet_id
  }
  
  # network {
  #   uuid = opentelekomcloud_vpc_subnet_v1.bastion_public_subnet.id
  # }

  user_data = base64encode(
    sensitive(
      join( 
        "\n", 
        [var.cloud_init_config],
        [data.template_file.security_cloud_config.rendered],
        [data.template_file.users_cloud_config.rendered] 
      )
    )
  )

  block_device {
    uuid                  = data.opentelekomcloud_images_image_v2.bastion_image.id
    source_type           = "image"
    volume_size           = var.system_disk_size
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
    volume_type           = var.system_disk_type
  }

  tags = var.tags 

  lifecycle {
    precondition {
      condition     = contains(data.opentelekomcloud_compute_availability_zones_v2.available_availability_zones.names, local.availability_zone)
      error_message = "Availability zone setting invalid. For the region ${local.region} the valid AZ's are ${jsonencode(data.opentelekomcloud_compute_availability_zones_v2.available_availability_zones.names)}"
    }
  }

}



# EIP for bastion

resource "opentelekomcloud_vpc_eip_v1" "bastion_public_ip" {
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "bandwidth"
    size        = var.eip_bandwidth
    share_type  = "PER"
    charge_mode = "traffic"
  }

  tags = var.tags 
}


# Bind the floating IP to bastion

resource "opentelekomcloud_networking_floatingip_associate_v2" "floatingip_associate_bastion" {
  floating_ip = opentelekomcloud_vpc_eip_v1.bastion_public_ip.publicip.0.ip_address
  port_id     = opentelekomcloud_compute_instance_v2.bastion.network.0.port
}
