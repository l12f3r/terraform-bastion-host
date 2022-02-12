provider "aws" {
  region = var.region
}

resource "aws_vpc" "ourVPC" {
  cidr_block = var.vpcCIDRBlock
  instance_tenancy = var.vpcInstanceTenancy

  tags = {
    Name = var.vpcName
  }
}

resource "aws_internet_gateway" "ourIGW" {
  vpc_id = [aws_vpc.ourVPC.id]

  tags = {
    Name = var.internetGatewayName
  }
}

resource "aws_subnet" "pubSub" {
  vpc_id = [aws_vpc.ourVPC.id]
  cidr_block = var.pubSubCIDRBlock
  availability_zone = var.pubSubAZ

  tags = {
    Name = var.pubSubName
  }
}

resource "aws_subnet" "privSub" {
  vpc_id = [aws_vpc.ourVPC.id]
  cidr_block = var.privSubCIDRBlock
  availability_zone = var.privSubAZ

  tags = {
    Name = var.privSubName
  }
}

resource "aws_instance" "bastionHost" {
  #other resource arguments will be later added
  depends_on = [aws_internet_gateway.ourIGW.id]

  tags = {
    Name = var.bastionHostName
  }
}
