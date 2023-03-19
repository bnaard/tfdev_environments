resource opentelekomcloud_vpc_v1 vpc_1 {
  name = var.vpc_name
  cidr = var.vpc_cidr

  tags = merge( var.tags, { function = "vpc"} )

}


resource "opentelekomcloud_vpc_subnet_v1" "dmz_subnet" {
  name       = "subnet_dmz"
  vpc_id     = opentelekomcloud_vpc_v1.vpc_1.id
  cidr       = var.dmz_subnet_cidr
  gateway_ip = cidrhost(var.dmz_subnet_cidr, 1) #  "192.168.1.1"

  tags = merge( var.tags, { function = "dmz" } )
}


resource "opentelekomcloud_vpc_subnet_v1" "management_subnet" {
  name       = "subnet_management"
  vpc_id     = opentelekomcloud_vpc_v1.vpc_1.id
  cidr       = var.management_subnet_cidr
  gateway_ip = cidrhost(var.management_subnet_cidr, 1) #  "192.168.1.1"

  tags = merge( var.tags, { function = "management" } )
}
