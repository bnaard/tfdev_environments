# General variables

variable "deployment_name" {
  type        = string
  description = "Identifies the deployment by name (eg. to destry everything at once)"
  default     = "opentelekomcloud_deployment"
}


variable "environment" {
  type        = string
  description = "Identifies environment type (eg development, production)"
}


variable "identity_endpoint" {
  type        = string
  description = "OTC URL for the API"
}

variable "access_key" {
  type        = string
  description = "OTC AK. Don't use together with username/password"
}

variable "secret_key" {
  type        = string
  description = "OTC SK. Don't use together with username/password"
}

variable "domain_name" {
  type        = string
  description = "OTC Domain"
}

variable "tenant_name" {
  type        = string
  description = "OTC tenant (i.e. project name)"
}

variable "vpc_name" {
  default = "opentelekomcloud_vpc"
}

variable "vpc_cidr" {
  default = "192.168.0.0/16"
}



# Bastion host specific variables

variable "bastion_subnet_cidr" {
    default = "192.168.1.0/24"
}

variable "bastion_region" {
  type        = string
  description = "OTC region"
}

variable "bastion_availability_zone" {
  type        = string
  description = "OTC availability zone for the bastion host an its attached disks"
  default     = "eu-de-01"
}

variable "bastion_flavor_name" {
  type        = string
  default     = "s3.medium.2"
  description = "Name of the compute ressource type"
}

variable "bastion_image_name" {
  type        = string
  default     = "Standard_Ubuntu_22.04_latest"
  description = "Name of the OTC source image"
}

# variable "bastion_ssh_user_name" {
#   type        = string
#   default     = "ubuntu"
#   description = "User name needed for default login at the OTC source image"
# }

variable "bastion_ssh_port" {
  type        = number
  default     = 22
  description = "SSH-port to access bastion host"
}

variable "bastion_ssh_access_constraint" {
  type        = string
  description = "CIDR of machines that are allowed to access the bastion host"
  default     = "0.0.0.0/0"
}

variable "bastion_system_disk_size" {
  type        = number
  default     = 20
  description = "Size of the system disk for the bastion host"
}

variable "bastion_paths_to_cloud_init_files" {
  description = "List of paths relative to main.tf to custom Cloud-init configuration files. Cloud-init cloud config format is expected. Only *.yml and *.yaml files will be read."
  type        = list(string)
  default     = [""]
}

variable "bastion_emergency_user" {
  description = "If set to *true*, a cloud-init config with an *bastion_emergency_ssh_key' for *bastion_emergency_user_spec* will be added."
  type        = bool
  default     = false
}

variable "bastion_emergency_user_spec" {
  description = "Name, groups, shell and public key of the emergency user for the bastion host. Must fit to the image/OS selected and/or to further cloud-init configurations applied."
  type = object({
    username        = string
    groups          = string
    shell           = string
    public_key_file = string
  })
  default = {
      username        = "emergency"
      groups          = "wheel"
      shell           = "/bin/bash"
      public_key_file = ""
    }
}





