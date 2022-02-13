# terraform-bastion-host

[@l12f3r](https://github.com/l12f3r) here, once again, to share how to create a bastion host (or "jump host", depending on jargon) on an AWS Virtual Private Cloud, using Terraform. This can be considered a beginner exercise for those interested in learning a bit more on networking, infrastructure as code and cloud computing.

For those who know me from the [lizferLinux exercise](https://github.com/l12f3r/lizferLinux), buckle your seatbelts because this is a new challenge. If it's your first time around, you can route back to it and take a look on how I usually document my own learning and share it on Github.

I'll try to provision everything (network, instances, security) using code and command line. For best practices, I'll use a `variables.tf` file to separate variables from the main infrastructure code (and to describe the use of each parameter), and a `parameters.auto.tfvars` file - that way, infrastructure parameters (such as instance type, region, and tags) can vary depending on preference (or necessity). And, of course, avoid hardcoding.

## 1. Prepare the environment

Terraform must be installed and configured in your environment: check how to install and configure it on [their website](https://www.terraform.io/downloads).

The `main.tf` file must have defined the cloud provider of preference and the logical region defined. I selected AWS and that's probably the only hardcoded information entered - other code references depend on this information. The region where your VPC will be provisioned should also be defined:

```terraform
# main.tf
provider "aws" {
  region = var.region
}
```

## 2. Create a VPC

Upon provisioning the Virtual Private Network (VPC), one may specify just some other instance details and have the VPC automatically provisioned with default values. However, such architecture would lack on autonomy.

```terraform
# main.tf
resource "aws_vpc" "ourVPC" {
  cidr_block = var.vpcCIDRBlock
  instance_tenancy = var.vpcInstanceTenancy

  tags = {
    Name = var.vpcName
  }
}
```

## 3. Create an internet gateway

An internet gateway is a logical device responsible for connecting the VPC to the internet.

From this point on, it's good practice to declare explicit dependencies using `depends_on`.

```terraform
# main.tf
resource "aws_internet_gateway" "ourIGW" {
  vpc_id = [aws_vpc.ourVPC.id]
  depends_on = [aws_vpc.ourVPC]

  tags = {
    Name = var.internetGatewayName
  }
}
```

## 4. Create subnets (public and private)

Within our VPC, subnets are logical clusters of instances that, although part of the same network, can be organised with different parameters to meet several needs.

The following lines of code contain some fundamental parameters for setting up two subnets: a public one (that is, open to receive internet traffic), for the bastion host, and another private one for the instances that will receive the bastion host access (and must not be connected to the internet).

Since that those subnets will be within the VPC's CIDR block, make sure to divide the useable IPs properly. In order to do so, I used [this visual subnet calculator I found online](https://www.davidc.net/sites/default/subnets/subnets.html).

```terraform
# main.tf
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
```

## 5. Create route tables and associate to subnets

Route tables are configuration patterns that define the connection behaviour of each subnet (how it connects to other resources). It's good practice to associate one route table to each subnet; in our scenario, the public route table must have routes to the internet (that is, to our internet gateway) and to our VPC, while the private one must be routed to our VPC only.

On Terraform code, there must be `resource`s for the route tables and for their associations with subnets. The default route, that maps the VPC's CIDR block to `local`, is created implicitly - therefore, the private route table does not require a `route` within a `resource`.

```terraform
# main.tf
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
```

## 6. Create public and private instances with security groups

OK - now that the whole network infrastructure is set, our instances must be created within our subnets and its security groups must be configured. Security groups are layers of security on the instance level, where the administrator defines what can connect to the resource and how (using which protocol).

The bastion host instance was drafted while creating the internet gateway; therefore, it must receive additional and necessary arguments (such as defining its public IP or AMI) to be functional.

There are many other attributes that could be used for more autonomy, but these selected are enough.

```terraform
# main.tf

# Bastion Host instance configuration
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
  depends_on = [aws_instance.bastionHost]

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

# Private instance configuration
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
  depends_on = [aws_instance.privInstance]

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
```

## 7. Configuring the bastion host security and access to the private instance
