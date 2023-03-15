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

# Create VPC for setup

resource opentelekomcloud_vpc_v1 vpc_1 {
  name = var.vpc_name
  cidr = var.vpc_cidr

  tags = merge( var.tags, { function = "vpc"} )

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
    source                    = "./modules/bastion"
    name                      = "bastion"  
    tags                      = merge( var.tags, { function = "bastion"} )
    vpc_id                    = opentelekomcloud_vpc_v1.vpc_1.id
    subnet_cidr               = var.bastion_subnet_cidr
    eip_bandwidth             = 5
    system_disk_size          = 5
    system_disk_type          = "SATA"
    availability_zone         = var.bastion_availability_zone
    flavor_name               = var.bastion_flavor_name
    image_name                = var.bastion_image_name
    ssh_port                  = var.bastion_ssh_port
    trusted_ssh_origins       = var.bastion_trusted_ssh_origins
    cloud_init_config         = join("\n", [for filepath in local.cloud_init_files : file(filepath)])
    emergency_user            = var.bastion_emergency_user
    emergency_user_spec       = var.bastion_emergency_user_spec
}

