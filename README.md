# terraform-bastion-host

[@l12f3r](https://github.com/l12f3r) here, once again, to share how to create a bastion host (or "jump host", depending on jargon) on an AWS Virtual Private Cloud, using Terraform. This can be considered a beginner exercise for those interested in learning a bit more on networking, infrastructure as code and cloud computing.

For those who know me from the [lizferLinux exercise](https://github.com/l12f3r/lizferLinux), buckle your seatbelts because this is a new challenge. If it's your first time around, you can route back to it and take a look on how I usually document my own learning and share it on Github.

I'll try to provision everything (network, instances, security) using code and command line. For best practices, I'll use a `variables.tf` file to separate variables from the main infrastructure code (and to describe the use of each parameter), and a `parameters.tfvars` file - that way, infrastructure parameters (such as instance type, region, and tags) can vary depending on preference (or necessity). And, of course, avoid hardcoding.

## 1. Prepare the environment

Terraform must be installed and configured in your environment: check how to install and configure it on [their website](https://www.terraform.io/downloads).

The `main.tf` file must have defined the cloud provider of preference and the logical region defined. I selected AWS and that's probably the only hardcoded information entered - other code references depend on this information. The region where your VPC will be provisioned should also be defined:

```terraform
# main.tf
provider "aws" {
  region = var.region
}
```

```terraform
# variables.tf
variable "region" {
  type = string
  description = "Region where all resources will be provisioned"
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

```terraform
# variables.tf
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
```

## 3. Create an internet gateway

An internet gateway is a logical device responsible for connecting the VPC to the internet. For this step, I decided to draft the provisioning of the bastion host instance, since that its dependency on the internet gateway must be also declared. It's OK to keep default settings, considering that this gateway is provisioned only upon the first `terraform apply` command and its data may not be changed on future runs.

```terraform
# main.tf
resource "aws_internet_gateway" "ourIGW" {
  vpc_id = [aws_vpc.ourVPC.id]

  tags = {
    Name = var.internetGatewayName
  }
}

resource "aws_instance" "bastionHost" {
  #other resource arguments will be later added
  depends_on = [aws_internet_gateway.ourIGW.id]

  tags = {
    Name = var.bastionHostName
  }
}
```

```terraform
# variables.tf
variable "internetGatewayName" {
  type = string
  description = "Nametag for the internet gateway"
}

variable "bastionHost" {
  type = string
  description = "Nametag for the bastion host instance"
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
```

```terraform
# variables.tf
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
```

## 5. Create route tables and associate to subnets

Route tables are configuration patterns that define the connection behaviour of each subnet (how it connects to other resources). It's good practice to associate one route table to each subnet; in our scenario, the public route table must have routes to the internet (that is, to our internet gateway) and to our VPC, while the private one must be routed to our VPC only.

On Terraform code, there must be `resource`s for the route tables and for their associations with subnets. The default route, that maps the VPC's CIDR block to `local`, is created implicitly - therefore, the private route table does not require a `route` within a `resource`.

```terraform
# main.tf
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
```

```terraform
# variables.tf
variable "pubRTName" {
  type = string
  description = "Nametag for the public route table"
}

variable "privRTName" {
  type = string
  description = "Nametag for the private route table"
}
```

## 6. create public (w/ public IP) and private instances (w/ security groups) in respective public and private subnets
