# public subnet for bastion host

resource "opentelekomcloud_vpc_subnet_v1" "bastion_public_subnet" {
  name       = "bastion_public_subnet"
  vpc_id     = var.vpc_id    # opentelekomcloud_vpc_v1.vpc_1.id
  cidr       = var.subnet_cidr
  gateway_ip = cidrhost(var.subnet_cidr, 1) #  "192.168.1.1"

  tags = var.tags 
}

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
    groups          = var.emergency_user_spec.groups
    sudo            = var.emergency_user_spec.sudo
    public_key_file = file(var.emergency_user_spec.public_key_file)
  }
}




# Create a bastion host

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name              = var.name
  image_name        = data.opentelekomcloud_images_image_v2.bastion_image.id
  flavor_id         = data.opentelekomcloud_compute_flavor_v2.bastion_flavor.id
  availability_zone = local.availability_zone
  security_groups   = [opentelekomcloud_networking_secgroup_v2.bastion_securitygroup.name]

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.bastion_public_subnet.id
  }

  user_data = base64encode(
    sensitive(
      join( 
        "\n", 
        [var.cloud_init_config],
        [data.template_file.security_cloud_config.rendered],
        [data.template_file.users_cloud_config.rendered] 
        # [local.cloud_init_emergency_user_config] ,
        # [for filepath in local.cloud_init_files : file(filepath)]
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
