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

variable "vpc_id" {
  type        = string
  description = "ID of VPC this bastion host belongs to."
}

variable "subnet_cidr" {
  default = "192.168.1.0/24"
}

variable "eip_bandwidth" {
  description = "Bandwidth of public IP access to bastion host."
  type        = number
  default     = 8
}

# variable "region" {
#   type        = string
#   description = "OTC region"
# }

# variable "availability_zone" {
#   type        = string
#   description = "OTC availability zone for the bastion host an its attached disks"
#   default     = "eu-de-01"
# }

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
    groups          = string
    shell           = string
    sudo            = string
    public_key_file = string
  })
  default = {
      username        = "emergency"
      groups          = ""
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

locals {
  valid_availability_zones = {
    eu-de = toset([
      "eu-de-01",
      "eu-de-02",
      "eu-de-03",
    ])
    eu-nl = toset([
      "eu-nl-01",
      "eu-nl-02",
      "eu-nl-03",
    ])
    eu-ch2 = toset([
      "eu-ch2a",
      "eu-ch2b",
    ])
  }
  region            = data.opentelekomcloud_identity_project_v3.current.region
  availability_zone = length(var.availability_zone) == 0 ? local.region == "eu-ch2" ? "eu-ch2b" : "${local.region}-02" : var.availability_zone
}

resource "errorcheck_is_valid" "availability_zone" {
  name = "Check if availability_zones are set up correctly for bastion host."
  test = {
    assert        = contains(local.valid_availability_zones[local.region], local.availability_zone)
    error_message = "Availability zone setting invalid. For ${local.region} the valid AZ's are ${jsonencode(local.valid_availability_zones[local.region])}"
  }
}
