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

resource "aws_internet_gateway" var.internetGatewayName {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.internetGatewayName
  }
}

resource "aws_instance" var.bastionHost {
  #other resource arguments will be later added
  depends_on = [aws_internet_gateway.var.internetGatewayName]

  tags = {
    Name = var.bastionHost
    }
}
