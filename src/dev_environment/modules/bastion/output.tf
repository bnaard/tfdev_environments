output "public_ip" {
  value = opentelekomcloud_vpc_eip_v1.bastion_public_ip.publicip[0].ip_address
}

output "debug_cloudinit_config" {
  value = join( 
        "\n", 
        [var.cloud_init_config], 
        [data.template_file.security_cloud_config.rendered], 
        [data.template_file.users_cloud_config.rendered] 
      )
}