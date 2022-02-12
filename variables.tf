variable "region" {
  type = string
  description = "Region where all resources will be provisioned"
}

variable "vpcCIDRBlock" {
  type = string
  description = "CIDR block of the VPN"
}

variable "vpcInstanceTenancy" {
  type = string
  description = "Tenancy option for instances launched into the VPC"
}

variable "vpcName" {
  type = string
  description = "Nametag for the VPC"
}

variable "internetGatewayName" {
  type = string
  description = "Nametag for the internet gateway"
}

variable "bastionHost" {
  type = string
  description = "Nametag for the bastion host instance"
}
