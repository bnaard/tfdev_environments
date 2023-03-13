# Personal Access related variables
access_key                        = "HRCFEZGMYZWZSPP4PBQL"
secret_key                        = "2KwHvjAlzKWtFg4lxpVU20dKF5UYUhjF31MpZ9Th"
domain_name                       = "OTC-EU-DE-00000000001000041249"
tenant_name                       = "eu-de" #"16016741 OTC-EU-DE-00000000001000041249"

# General variables
deployment_name                   = "bastion_first"
environment                       = "development"
identity_endpoint                 = "https://iam.eu-de.otc.t-systems.com/v3"
vpc_cidr                          = "192.168.0.0/16"

# Bastion host configuration
bastion_subnet_cidr               = "192.168.1.0/24"
bastion_region                    = "eu-de"
bastion_availability_zone         = "eu-de-01"
bastion_flavor_name               = "s2.large.4" # "s2.medium.2"
bastion_image_name                = "Standard_Ubuntu_22.04_latest"
# bastion_ssh_user_name             = "ubuntu"
bastion_ssh_port                  = 22
bastion_ssh_access_constraint     = "0.0.0.0/0"
bastion_paths_to_cloud_init_files = ["./cloud-init"]
bastion_emergency_user            = true
bastion_emergency_user_spec       = { username = "emergency", groups = "[users, ubuntu]", shell = "/bin/bash", public_key_file = "/Users/bernhardgerlach/Documents/53I1_Passwords/SSH-Keys/OTC-EU-DE-00000000001000041249/KeyPair-c8a8/KeyPair-c8a8_id_rsa.pub" }
