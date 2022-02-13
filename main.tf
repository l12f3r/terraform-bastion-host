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
  depends_on = [aws_vpc.ourVPC]

  tags = {
    Name = var.internetGatewayName
  }
}

resource "aws_subnet" "pubSub" {
  vpc_id = [aws_vpc.ourVPC.id]
  cidr_block = var.pubSubCIDRBlock
  availability_zone = var.pubSubAZ
  depends_on = [aws_internet_gateway.ourIGW]

  tags = {
    Name = var.pubSubName
  }
}

resource "aws_subnet" "privSub" {
  vpc_id = [aws_vpc.ourVPC.id]
  cidr_block = var.privSubCIDRBlock
  availability_zone = var.privSubAZ
  depends_on = [aws_internet_gateway.ourIGW]

  tags = {
    Name = var.privSubName
  }
}

resource "aws_route_table" "pubRT" {
  vpc_id = [aws_vpc.ourVPC.id]
  depends_on = [aws_subnet.pubSub]

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
  depends_on = [aws_subnet.privSub]

  tags = {
    Name = var.privRTName
  }
}

resource "aws_route_table_association" "pubRTToSub" {
  subnet_id = [aws_subnet.pubSub.id]
  route_table_id = [aws_route_table.pubRT.id]
  depends_on = [aws_route_table.pubRT]
}

resource "aws_route_table_association" "privRTToSub" {
  subnet_id = [aws_subnet.privSub.id]
  route_table_id = [aws_route_table.privRT.id]
  depends_on = [aws_route_table.privRT]
}

resource "aws_instance" "bastionHost" {
  ami = var.bastionHostAMI
  instance_type = var.bastionHostInstanceType
  vpc_security_group_ids = [aws_security_group.bastionHostSG]
  depends_on = [aws_subnet.pubSub]

  tags = {
    Name = var.bastionHostName
  }
}

resource "aws_security_group" "bastionHostSG" {
  vpc_id = [aws_vpc.ourVPC.id]

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = var.bastionHostSGCIDRBlock
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.bastionHostSGCIDRBlock
  }

  tags = {
    Name = var.bastionHostSGName
  }
}

resource "aws_instance" "privInstance" {
  ami = var.privInstAMI
  instance_type = var.privInstInstanceType
  vpc_security_group_ids = [aws_security_group.privInstSG]
  depends_on = [aws_subnet.privSub]

  tags = {
    Name = var.privInstName
  }
}

resource "aws_security_group" "privInstSG" {
  vpc_id = [aws_vpc.ourVPC.id]

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [aws_instance.bastionHost.private_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.privInstSGCIDRBlock
  }

  tags = {
    Name = var.privInstSGName
  }
}
