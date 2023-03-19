locals {
  aksk_csv_file_content = csvdecode(file(var.aksk_file))
  ak                    = local.aksk_csv_file_content[0]["Access Key Id"]
  sk                    = local.aksk_csv_file_content[0]["Secret Access Key"]
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  access_key  = local.ak
  secret_key  = local.sk
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url    = var.identity_endpoint
}



locals {
  cloud_init_files = flatten([
    for path_to_cloud_init in var.bastion_paths_to_cloud_init_files : [
      for path in fileset("", "${path_to_cloud_init}/*.{yml,yaml}") : path
    ]
  ])
}


module "bastion" {
    count                     = 1
    source                    = "./modules/hardened-ecs"
    name                      = "bastion"  
    tags                      = merge( var.tags, { function = "bastion"} )
    subnet_id                 = opentelekomcloud_vpc_subnet_v1.dmz_subnet.id
    eip_bandwidth             = 5
    system_disk_size          = 7
    system_disk_type          = "SATA"
    availability_zone         = var.bastion_availability_zone
    flavor_name               = var.bastion_flavor_name
    image_name                = var.bastion_image_name
    ssh_port                  = var.bastion_ssh_port
    trusted_ssh_origins       = var.bastion_trusted_ssh_origins
    cloud_init_config         = join("\n", [for filepath in local.cloud_init_files : file(filepath)])
    emergency_user            = var.emergency_user
    emergency_user_spec       = var.emergency_user_spec
}


module "om_ansible" {
    count                     = 1
    source                    = "./modules/hardened-ecs"
    name                      = "om_ansible"  
    tags                      = merge( var.tags, { function = "om_ansible"} )
    subnet_id                 = opentelekomcloud_vpc_subnet_v1.management_subnet.id
    eip_bandwidth             = 5
    system_disk_size          = 10
    system_disk_type          = "SATA"
    availability_zone         = var.bastion_availability_zone
    flavor_name               = "s3.medium.2"
    image_name                = "Standard_Ubuntu_22.04_latest"
    ssh_port                  = 22
    trusted_ssh_origins       = flatten([ for bastion in module.bastion : bastion.access_ip_v4 ])
    cloud_init_config         = ""
    emergency_user            = var.emergency_user
    emergency_user_spec       = var.emergency_user_spec
}

