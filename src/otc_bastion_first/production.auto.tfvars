# Access related variables
access_key                  = "HRCFEZGMYZWZSPP4PBQL"
secret_key                  = "2KwHvjAlzKWtFg4lxpVU20dKF5UYUhjF31MpZ9Th"
domain_name                 = "OTC-EU-DE-00000000001000041249"
tenant_name                 = "eu-de" #"16016741 OTC-EU-DE-00000000001000041249"
bastion_admin_key_name      = "KeyPair-c8a8" 

# General variables
environment                 = "development"
identity_endpoint           = "https://iam.eu-de.otc.t-systems.com/v3"

# Bastion host configuration
bastion_region              = "eu-de"
bastion_availability_zone   = "az1"
bastion_flavor_name         = "s3.medium.2"
# bastion_resource_type       = "s3.medium.2"
# bastion_vcpus               = 2
# bastion_ram                 = 8
bastion_image_name          = "Standard_Ubuntu_22.04_latest"
bastion_ssh_user_name       = "ubuntu"

