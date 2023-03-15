# General variables

variable "tags" {
  type        = map(string)
  description = "Identifies the deployment based on tags."
}

variable "identity_endpoint" {
  type        = string
  description = "OTC URL for the API"
}

variable "aksk_file" {
  type        = string
  description = "File for AK/SK (CSV-format as downloaded from Open Telekom Cloud)"
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


## Bastion host related

variable "bastion_subnet_cidr" {
  default = "192.168.1.0/24"
}

variable "bastion_eip_bandwidth" {
  description = "Bandwidth of public IP access to bastion host."
  type        = number
  default     = 8
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

variable "bastion_ssh_port" {
  type        = number
  default     = 22
  description = "SSH-port to access bastion host"
}

variable "bastion_trusted_ssh_origins" {
  type        = list(string)
  description = "CIDR of machines that are allowed to access the bastion host"
  default     = ["0.0.0.0/0"]
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
  description = "If set to *true*, a cloud-init config with an *emergency_ssh_key' for *emergency_user_spec* will be added."
  type        = bool
  default     = false
}

variable "bastion_emergency_user_spec" {
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




