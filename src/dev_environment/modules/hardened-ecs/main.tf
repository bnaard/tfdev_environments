data "opentelekomcloud_images_image_v2" "image" {
  name = var.image_name
}

data "opentelekomcloud_compute_flavor_v2" "flavor" {
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
    gecos           = "Emergency user"
    lock_passwd     = true
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



resource "opentelekomcloud_compute_instance_v2" "node" {
  name              = var.name
  image_name        = data.opentelekomcloud_images_image_v2.image.id
  flavor_id         = data.opentelekomcloud_compute_flavor_v2.flavor.id
  availability_zone = local.availability_zone
  security_groups   = [opentelekomcloud_networking_secgroup_v2.node_securitygroup.name]

  network {
    uuid            = var.subnet_id
    fixed_ip_v4     = var.fixed_ip_v4
  }
  
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
    uuid                  = data.opentelekomcloud_images_image_v2.image.id
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
      error_message = "For node ${var.name}, availability zone setting is invalid. For the region ${local.region} the valid AZ's are ${jsonencode(data.opentelekomcloud_compute_availability_zones_v2.available_availability_zones.names)}"
    }
  }

}


resource "opentelekomcloud_vpc_eip_v1" "public_ip" {
  count       = var.create_public_ip ? 1 : 0
  publicip {
    type = "5_bgp"
  }
  bandwidth {
    name        = "bandwidth"
    size        = var.eip_bandwidth
    share_type  = "PER"
    charge_mode = "traffic"
  }

  tags        = var.tags 
}


resource "opentelekomcloud_networking_floatingip_associate_v2" "floatingip_associate" {
  count       = var.create_public_ip ? 1 : 0
  floating_ip = opentelekomcloud_vpc_eip_v1.public_ip[0].publicip.0.ip_address
  port_id     = opentelekomcloud_compute_instance_v2.node.network.0.port
}
