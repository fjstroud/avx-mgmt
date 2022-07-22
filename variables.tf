variable "admin_password" {
  default   = ""
  sensitive = true
}

variable "aws_account_id" {
  type = string
  sensitive = true
}

variable "aws_account_name" {
  default = "aws"
}

variable "admin_email" {
  default   = ""
  sensitive = true
}

variable "controller_kp" {
  default = "controller_kp"
}

variable "incoming_ssl_cidr" {
  type    = list(any)
  default = ["10.0.0.0/16"]
}

variable "controller_vpc_cidr_block" {
  description = "controller vpc cidr block"
  default     = "10.0.0.0/16"
}

variable "controller_subnet_cidr" {
  description = "subnet the controller will be deployed"
  default     = "10.0.1.0/24"

}


variable "customer_license_id" {

  default     = ""
  description = "controller license"
}

variable "type" {
  default     = "BYOL"
  description = "Type of controller license.  Valid values are MeteredPlatinumCopilot, BYOL and Custom"

}
