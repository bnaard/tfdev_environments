output "bastion_public_ip" {
  value = [ for bastion in module.bastion : bastion.public_ip]
}

output "bastion_access_ip" {
  value = [ for bastion in module.bastion : bastion.access_ip_v4]
}

output "om_ansible_access_ip" {
  value = [ for om_ansible in module.om_ansible : om_ansible.access_ip_v4]
}


output "debug_cloudinit_config" {
  value = [ for bastion in module.bastion : bastion.debug_cloudinit_config]
}
