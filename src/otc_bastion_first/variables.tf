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

variable "bastion_admin_key_name" {
  type        = string
  description = "Key name from user rolling out the bastion host"
}

variable "bastion_admin_public_key_file" {
  type        = string
  description = "Public Key file name for the bastion host"
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

variable "bastion_ssh_user_name" {
  type        = string
  default     = "ubuntu"
  description = "User name needed for default login at the OTC source image"
}

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

# variable "bastion_system_disk_availability_zone" {
#   type        = string
#   description = "Availability disk for the system disk of the bastion host"
#   default     = "eu-de-01"
# }

variable "bastion_system_disk_size" {
  type        = number
  default     = 20
  description = "Size of the system disk for the bastion host"
}
