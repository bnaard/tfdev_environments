output "public_ip" {
  value = length(opentelekomcloud_vpc_eip_v1.public_ip) > 0 ? opentelekomcloud_vpc_eip_v1.public_ip[0].publicip[0].ip_address : null
}

output "access_ip_v4" {
  value = opentelekomcloud_compute_instance_v2.node.access_ip_v4
}


output "debug_cloudinit_config" {
  value = join( 
        "\n", 
        [var.cloud_init_config], 
        [data.template_file.security_cloud_config.rendered], 
        [data.template_file.sshd_config.rendered],
        [data.template_file.users_cloud_config.rendered] 
      )
}