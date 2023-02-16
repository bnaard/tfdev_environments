terraform {
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">= 1.32.3"
    }
  }
}


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

provider "opentelekomcloud" {
  access_key  = var.access_key
  secret_key  = var.secret_key
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url    = var.identity_endpoint
}

resource "opentelekomcloud_compute_instance_v2" "basic" {
  name            = "basic"
  image_name      = "Standard_Ubuntu_22.04_latest"
  flavor_id       = "s2.large.4"
  security_groups = ["default"]

  metadata = {
    this = "that"
  }

  tags = {
    muh = "kuh"
  }
}