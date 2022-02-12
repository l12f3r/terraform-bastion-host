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

resource "aws_route_table" "pubRT" {
  vpc_id = [aws_vpc.ourVPC.id]

  route {
    cidr_block = var.pubRTCIDRBlock
    gateway_id = [aws_internet_gateway.ourIGW.id]
  }

  tags = {
    Name = var.pubRTName
  }
}

resource "aws_route_table" "privRT" {
  vpc_id = [aws_vpc.ourVPC.id]

  tags = {
    Name = var.privRTName
  }
}

resource "aws_route_table_association" "pubRTToSub" {
  subnet_id = [aws_subnet.pubSub.id]
  route_table_id = [aws_route_table.pubRT.id]
}

resource "aws_route_table_association" "privRTToSub" {
  subnet_id = [aws_subnet.privSub.id]
  route_table_id = [aws_route_table.privRT.id]
}

resource "aws_instance" "bastionHost" {
  #other resource arguments will be later added
  depends_on = [aws_internet_gateway.ourIGW.id]

  tags = {
    Name = var.bastionHostName
  }
}
