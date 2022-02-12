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

variable "pubSubCIDRBlock" {
  type = string
  description = "CIDR block of the public subnet"
}

variable "pubSubAZ" {
  type = string
  description = "Availability zone of the public subnet"
}

variable "pubSubName" {
  type = string
  description = "Nametag of the public subnet"
}

variable "privSubCIDRBlock" {
  type = string
  description = "CIDR block of the private subnet"
}

variable "privSubAZ" {
  type = string
  description = "Availability zone of the private subnet"
}

variable "privSubName" {
  type = string
  description = "Nametag of the private subnet"
}

variable "pubRTCIDRBlock" {
  type = string
  description = "CIDR Block for the public route table"
}

variable "pubRTName" {
  type = string
  description = "Nametag for the public route table"
}

variable "privRTName" {
  type = string
  description = "Nametag for the private route table"
}

variable "bastionHostName" {
  type = string
  description = "Nametag for the bastion host instance"
}
