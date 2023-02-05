# General variables

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


# Bastion host specific variables

variable "bastion_admin_key_name" {
  type        = string
  description = "Key name from user rolling out the bastion host"
}

variable "bastion_region" {
  type        = string
  description = "OTC region"
}

variable "bastion_availability_zone" {
  type        = string
  description = "OTC availability zone"
}

variable "bastion_flavor_name" {
  type        = string
  default     = "s3.medium.2"
  description = "Name of the compute ressource type"
}

# variable "bastion_resource_type" {
#   type        = string
#   description = "Name of the compute ressource type"
# }

# variable "bastion_vcpus" {
#   type        = number
#   description = "Number of vcpus"
# }

# variable "bastion_ram" {
#   type        = number
#   description = "RAM in GBytes"
# }


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