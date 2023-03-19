variable "name" {
  type        = string
  default     = "hardened_ecs"
  description = "Name of virtual machine (default: \"hardened_ecs\")"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the virtual machine (default: n/a)."
}

variable "subnet_id" {
  type        = string
  description = "ID of subnet this virtual machine belongs to (default: n/a)."
}

variable "create_public_ip" {
  type        = bool
  default     = false
  description = "If true, creates a public IP for the virtual machine and provides the IPv4 address as output (default: false)."
}


variable "eip_bandwidth" {
  description = "Bandwidth of public IP access to the virtual machine (default: 8)."
  type        = number
  default     = 8
}

variable "flavor_name" {
  type        = string
  default     = "s3.medium.2"
  description = "Name of the compute ressource type (default: \"s3.medium.2\")"
}

variable "image_name" {
  type        = string
  default     = "Standard_Ubuntu_22.04_latest"
  description = "Name of the OTC source image (default: \"Standard_Ubuntu_22.04_latest\")"
}

variable "ssh_port" {
  type        = number
  default     = 22
  description = "SSH-port to access bastion host (default: 22)"
}

variable "fixed_ip_v4" {
  type        = string
  default     = ""
  description = "Fixed IPv4 address applied, if left non-empty (default: \"\")"
}


variable "trusted_ssh_origins" {
  description = "IP addresses and/or ranges allowed to SSH into the virtual machine. (default: [\"0.0.0.0/0\"] (Allow access from all IP addresses.))"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}


variable "system_disk_size" {
  type        = number
  default     = 10
  description = "Size of the system disk for the virtual machine (default: 10)"
}

variable "system_disk_type" {
  description = "Virtual machine system disk storage type. Must be one of \"SATA\", \"SAS\", or \"SSD\". (default: SATA)"
  default     = "SATA"
  validation {
    condition     = contains(["SATA", "SAS", "SSD"], var.system_disk_type)
    error_message = "Allowed values for system_disk_type are \"SATA\", \"SAS\", or \"SSD\"."
  }
}

variable "cloud_init_config" {
  description = "Cloud-init configuration (multi-line string) used as user-data for bastion host (default: \"\")."
  type        = string
  default     = ""
}

variable "emergency_user" {
  description = "If set to *true*, a cloud-init config with an *emergency_ssh_key' for *emergency_user_spec* will be added (default: false)."
  type        = bool
  default     = false
}

variable "emergency_user_spec" {
  description = "Name, groups, shell and public key of the emergency user for the virtual machine. Must fit to the image/OS selected and/or to further cloud-init configurations applied (default: username = \"emergency\", groups = [\"\"], shell = \"/bin/bash\", sudo = \"false\", public_ley_file = \"\" )."
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
  description = "Availability zone for the virtual machine."
  default     = ""
}
