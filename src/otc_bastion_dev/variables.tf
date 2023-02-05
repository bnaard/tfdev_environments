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

variable "region" {
  type        = string
  description = "OTC region"
}

variable "availability_zone" {
  type        = string
  description = "OTC availability zone"
}

variable "username" {
  type        = string
  description = "Don't use together with AK/SK"
}

variable "password" {
  type        = string
  description = "Don't use together with AK/SK"
}

variable "image_name" {
  type        = string
  default     = "Standard_Ubuntu_22.04_latest"
  description = "Name of the OTC source image"
}

variable "ssh_user_name" {
  type        = string
  default     = "ubuntu"
  description = "User name needed for default login at the OTC source image"
}