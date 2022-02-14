provider "aws" {
  region = var.region
}

resource "aws_default_vpc" "ourVPC" {

  tags = {
    Name = var.vpcName
  }
}

resource "aws_subnet" "pubSub" {
  vpc_id = aws_default_vpc.ourVPC.id
  availability_zone = var.pubSubAZ
  depends_on = [aws_default_vpc.ourVPC]

  tags = {
    Name = var.pubSubName
  }
}

resource "aws_subnet" "privSub" {
  vpc_id = aws_default_vpc.ourVPC.id
  availability_zone = var.privSubAZ
  depends_on = [aws_default_vpc.ourVPC]

  tags = {
    Name = var.privSubName
  }
}

resource "aws_route_table" "pubRT" {
  vpc_id = aws_default_vpc.ourVPC.id
  depends_on = [aws_subnet.pubSub]

  tags = {
    Name = var.pubRTName
  }
}

resource "aws_route_table" "privRT" {
  vpc_id = aws_default_vpc.ourVPC.id
  depends_on = [aws_subnet.privSub]

  tags = {
    Name = var.privRTName
  }
}

resource "aws_route_table_association" "pubRTToSub" {
  subnet_id = aws_subnet.pubSub.id
  route_table_id = aws_route_table.pubRT.id
  depends_on = [aws_route_table.pubRT]
}

resource "aws_route_table_association" "privRTToSub" {
  subnet_id = aws_subnet.privSub.id
  route_table_id = aws_route_table.privRT.id
  depends_on = [aws_route_table.privRT]
}

resource "aws_instance" "bastionHost" {
  ami = var.bastionHostAMI
  instance_type = var.bastionHostInstanceType
  vpc_security_group_ids = [aws_security_group.bastionHostSG.id]
  depends_on = [aws_security_group.bastionHostSG]

  tags = {
    Name = var.bastionHostName
  }
}

resource "aws_security_group" "bastionHostSG" {
  vpc_id = aws_default_vpc.ourVPC.id
  depends_on = [aws_route_table.pubRT]

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.bastionHostSGName
  }
}

resource "aws_instance" "privInstance" {
  ami = var.privInstAMI
  instance_type = var.privInstInstanceType
  vpc_security_group_ids = [aws_security_group.privInstSG.id]
  depends_on = [aws_security_group.privInstSG]

  tags = {
    Name = var.privInstName
  }
}

resource "aws_security_group" "privInstSG" {
  vpc_id = aws_default_vpc.ourVPC.id
  depends_on = [aws_route_table.privRT]

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.privInstSGName
  }
}

resource "aws_security_group_rule" "privInstSGRule" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  security_group_id = "aws_security_group.bastionHostSG.id"
  depends_on = [aws_security_group.bastionHostSG]
}
