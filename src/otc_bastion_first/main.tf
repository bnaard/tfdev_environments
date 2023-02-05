# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url    = var.identity_endpoint
}



# Bastion-related 

# data "opentelekomcloud_compute_flavor_v2" "bastion_flavor" {
# #  vcpus         = var.bastion_vcpus
# #  ram           = var.bastion_ram
#   resource_type = var.bastion_resource_type
# }

# data "opentelekomcloud_images_image_v2" "bastion_image" {
#   name = var.bastion_image_name
# }


# Create a bastion host
resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name              = format("%s_bastion", var.environment)
  image_id          = var.bastion_image_name # data.opentelekomcloud_images_image_v2.bastion_image.id
  flavor_id         = var.bastion_flavor_name   # data.opentelekomcloud_compute_flavor_v2.bastion_flavor.id
  key_pair          = var.bastion_admin_key_name
  availability_zone = var.bastion_availability_zone
  security_groups   = ["default"]

  network {
    name = "ssh_public_access_network"
  }

  tags = {
    workspace = var.environment
    function  = "BASTION"
  }
}
