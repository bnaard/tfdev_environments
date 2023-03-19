# Bastion host specific variables

variable "name" {
  type        = string
  default     = "bastion"
  description = "Name of bastion host virtual machine"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to bastion host."
}

variable "subnet_id" {
  type        = string
  description = "ID of subnet this bastion host belongs to."
}

variable "eip_bandwidth" {
  description = "Bandwidth of public IP access to bastion host."
  type        = number
  default     = 8
}

variable "flavor_name" {
  type        = string
  default     = "s3.medium.2"
  description = "Name of the compute ressource type"
}

variable "image_name" {
  type        = string
  default     = "Standard_Ubuntu_22.04_latest"
  description = "Name of the OTC source image"
}

variable "ssh_port" {
  type        = number
  default     = 22
  description = "SSH-port to access bastion host"
}

variable "trusted_ssh_origins" {
  description = "IP addresses and/or ranges allowed to SSH into the jumphost. (default: [\"0.0.0.0/0\"] (Allow access from all IP addresses.))"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


variable "system_disk_size" {
  type        = number
  default     = 10
  description = "Size of the system disk for the bastion host (default: 10)"
}

variable "system_disk_type" {
  description = "Bastion host system disk storage type. Must be one of \"SATA\", \"SAS\", or \"SSD\". (default: SATA)"
  default     = "SATA"
  validation {
    condition     = contains(["SATA", "SAS", "SSD"], var.system_disk_type)
    error_message = "Allowed values for system_disk_type are \"SATA\", \"SAS\", or \"SSD\"."
  }
}

variable "cloud_init_config" {
  description = "Cloud-init configuration (multi-line string) used as user-data for bastion host."
  type        = string
  default     = ""
}

variable "emergency_user" {
  description = "If set to *true*, a cloud-init config with an *emergency_ssh_key' for *emergency_user_spec* will be added."
  type        = bool
  default     = false
}

variable "emergency_user_spec" {
  description = "Name, groups, shell and public key of the emergency user for the bastion host. Must fit to the image/OS selected and/or to further cloud-init configurations applied."
  type = object({
    username        = string
    groups          = list(string)
    shell           = string
    sudo            = string
    public_key_file = string
  })
  default = {
      username        = "emergency"
      groups          = [""]
      shell           = "/bin/bash"
      sudo            = "False"
      public_key_file = ""
    }
}


variable "availability_zone" {
  type        = string
  description = "Availability zone for the bastion host."
  default     = ""
}
