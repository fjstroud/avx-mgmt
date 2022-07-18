

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

data "http" "icanhazip" {
  url = "http://icanhazip.com"
}


resource "aws_vpc" "controller" {
  cidr_block = var.controller_vpc_cidr_block

  tags = {
    Name = "controller_vpc"
  }
}

resource "aws_internet_gateway" "controller" {
  vpc_id = aws_vpc.controller.id

  tags = {
    Name = "controller_igw"
  }
}


resource "aws_subnet" "controller" {
  vpc_id     = aws_vpc.controller.id
  cidr_block = var.controller_subnet_cidr

  tags = {
    Name = "controller_public_subnet"
  }
}

resource "aws_route_table" "controller" {
  vpc_id = aws_vpc.controller.id

  route {
    cidr_block = var.default_route
    gateway_id = aws_internet_gateway.controller.id
  }


  tags = {
    Name = "controller_public_rt"
  }
}

resource "aws_route_table_association" "controller" {
  subnet_id      = aws_subnet.controller.id
  route_table_id = aws_route_table.controller.id
}

module "aviatrix-iam-roles" {
  source = "github.com/fjstroud/terraform-modules.git//aviatrix-controller-iam-roles?ref=master"
}

module "aviatrix-controller-build" {
  source            = "github.com/fjstroud/terraform-modules.git//aviatrix-controller-build?ref=master"
  vpc               = aws_vpc.controller.id
  subnet            = aws_subnet.controller.id
  keypair           = var.controller_kp
  ec2role           = module.aviatrix-iam-roles.aviatrix-role-ec2-name
  incoming_ssl_cidr = ["${chomp(data.http.icanhazip.body)}/32", var.controller_subnet_cidr, "${module.copilot_build_aws.public_ip}/32"]
}

module "aviatrix_controller_init" {
  source              = "github.com/fjstroud/terraform-modules.git//aviatrix-controller-initialize?ref=master"
  admin_email         = var.admin_email
  admin_password      = var.admin_password
  private_ip          = module.aviatrix-controller-build.private_ip
  public_ip           = module.aviatrix-controller-build.public_ip
  access_account_name = var.aws_account_name
  aws_account_id      = var.aws_account_id
  vpc_id              = aws_vpc.controller.id
  subnet_id           = aws_subnet.controller.id
  customer_license_id = var.customer_license_id
}

module "copilot_build_aws" {
  source            = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_aws"
  keypair           = "copilot_kp"
  use_existing_vpc  = true
  availability_zone = aws_subnet.controller.availability_zone
  vpc_id            = aws_vpc.controller.id
  subnet_id         = aws_subnet.controller.id

  allowed_cidrs = {
    "tcp_cidrs" = {
      protocol = "tcp"
      port     = "443"
      cidrs    = ["${chomp(data.http.icanhazip.body)}/32", "${module.aviatrix-controller-build.public_ip}/32"]
    }
    "udp_cidrs_1" = {
      protocol = "udp"
      port     = "5000"
      cidrs    = ["0.0.0.0/0"]
    }
    "udp_cidrs_2" = {
      protocol = "udp"
      port     = "31283"
      cidrs    = ["0.0.0.0/0"]
    }
  }
}
