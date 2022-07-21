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
terraform {
  cloud {
    hostname     = "app.terraform.io"
    organization = "cloudsilverlining"
    workspaces {
      tags = ["avx-controller"]
    }
  }
}

provider "aviatrix" {
  username      = "admin"
  password      = module.aviatrix-controller-build.private_ip
  controller_ip = module.aviatrix-controller-build.public_ip
}

provider "aws" {
  region = "ap-southeast-2"
}

