provider "aws" {
  region = var.region
}

resource "aws_vpc" var.vpcName {
  cidr_block = var.vpcCIDRBlock
  instance_tenancy = var.vpcInstanceTenancy

  tags = {
    Name = var.vpcName
  }
}
