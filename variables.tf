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

variable "bastionHostAMI" {
  type = string
  description = "AMI for the bastion host instance"
}

variable "bastionHostInstanceType" {
  type = string
  description = "Instance type for the bastion host"
}

variable "bastionHostName" {
  type = string
  description = "Nametag for the bastion host instance"
}

variable "bastionHostSGName" {
  type = string
  description = "Nametag for the bastion host security group"
}

variable "privInstAMI" {
  type = string
  description = "AMI for the private instance"
}

variable "privInstInstanceType" {
  type = string
  description = "Instance type for the private instance"
}

variable "privInstName" {
  type = string
  description = "Nametag for the private instance"
}

variable "privInstSGName" {
  type = string
  description = "Nametag for the private instance security group"
}
