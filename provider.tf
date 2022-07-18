terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.22.0"
    }
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "2.20.1"
    }
  }
}


provider "aviatrix" {
  username      = "admin"
  password      = module.aviatrix-controller-build.private_ip
  controller_ip = module.aviatrix-controller-build.public_ip
}

