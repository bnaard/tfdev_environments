output "bastion_public_ip" {
  value = opentelekomcloud_vpc_eip_v1.bastion_public_ip.publicip[0].ip_address
}