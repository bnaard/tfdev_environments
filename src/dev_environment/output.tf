output "bastion_public_ip" {
  value = [ for bastion in module.bastion : bastion.public_ip]
}

output "debug_cloudinit_config" {
  value = [ for bastion in module.bastion : bastion.debug_cloudinit_config]
}
