# terraform-bastion-host

NOTE: I'm Terragrunting everything in this branch. This README file might be a bit obsolete or out of place, but I'm keeping it for the sake of archiving.

[@l12f3r](https://github.com/l12f3r) here, once again, to share how to create a bastion host (or "jump host", depending on jargon) on an AWS Virtual Private Cloud, using Terraform. This can be considered a beginner exercise for those interested in learning a bit more on networking, infrastructure as code and cloud computing.

For those who know me from the [lizferLinux exercise](https://github.com/l12f3r/lizferLinux), buckle your seatbelts because this is a new challenge. If it's your first time around, you can route back to it and take a look on how I usually document my own learning and share it on Github.

I'll try to provision everything (network, instances, security) using code and command line. For best practices, I'll use a `variables.tf` file to separate variables from the main infrastructure code (and to describe the use of each parameter), and a `parameters.auto.tfvars` file - that way, infrastructure parameters (such as instance type, region, and tags) can vary depending on preference (or necessity). And, of course, avoid hardcoding.

## 1. Prepare the environment

Terraform must be installed and configured in your environment: check how to install and configure it on [their website](https://www.terraform.io/downloads).

A `providers.tf` file must be created, defining the cloud provider of preference and the logical region selected. The region where your VPC will be provisioned should also be defined:

```terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

```

## 2. Create a VPC

For this Terragrunt scenario, I'm using the AWS module. Maybe it doesn't break as much as it was during recent debug sessions.

### Create subnets (public and private)

Within our VPC, subnets are logical clusters/groups of interconnected instances that, although part of the same VPC, can be organised with different parameters to meet several needs.

Those can be defined on code, by stating the CIDR blocks to be used, along with the availability zones where it will be deployed.

```terraform
# main.tf
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpcName
  cidr = var.vpcCIDRBlock

  azs             = var.azs
  private_subnets = var.privSubCIDRBlock
  public_subnets  = var.pubSubCIDRBlock

  enable_nat_gateway = false
  enable_vpn_gateway = true
}
```

## 3. Create route tables and associate to subnets

Route tables are configuration patterns that define the connection behaviour of each subnet (how it connects to other resources).

It's good practice to associate one route table to each subnet; to do so, the `aws_route_table_association` resource must be used.

```terraform
# main.tf
resource "aws_route_table" "pubRT" {
  vpc_id = aws_vpc.ourVPC.id
  depends_on = [aws_subnet.pubSub]

  tags = {
    Name = var.pubRTName
  }
}

resource "aws_route_table" "privRT" {
  vpc_id = aws_vpc.ourVPC.id
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
```

## 4. Create security groups and its rules

Security groups are layers of security on the instance level, where the administrator defines what can connect to the resource and how (using which protocol) using security group rules.

To set up our scenario (where the public route table must point to the internet and to our VPC, while the private one must be routed to our VPC only), the private instance security group must state that only SSH connections from the bastion host security group should be accepted.

```terraform
# main.tf
resource "aws_security_group" "bastionHostSG" {
  vpc_id = aws_vpc.ourVPC.id
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

resource "aws_security_group" "privInstSG" {
  vpc_id = aws_vpc.ourVPC.id
  depends_on = [aws_route_table.privRT]

  ingress {
    description = "SSH from Bastion Host Security Group"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups  = [aws_security_group.bastionHostSG.id]
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
```

## 5. Create the bastion host and the private instance

The EC2 instances must be attached to each of our security groups, created within each of our subnets. For autonomy reasons, I am including details such as AMI and instance type to select.

```terraform
#main.tf
resource "aws_instance" "bastionHost" {
  ami = var.bastionHostAMI
  instance_type = var.bastionHostInstanceType
  vpc_security_group_ids = [aws_security_group.bastionHostSG.id]
  subnet_id = aws_subnet.pubSub.id
  depends_on = [aws_security_group.bastionHostSG]
  user_data = <<-EOF
  #!/bin/bash -ex
  yum update -y
  yum install -y httpd.x86_64
  systemctl start httpd.service
  systemctl enable httpd.service
  echo “IF YOU CAN READ THIS, YOUR BASTION HOST INSTANCE IS CONFIGURED CORRECTLY. NOW SSH INTO THE PRIVATE HOST!” > /var/www/html/index.html
  EOF

  tags = {
    Name = var.bastionHostName
  }
}

resource "aws_instance" "privInstance" {
  ami = var.privInstAMI
  instance_type = var.privInstInstanceType
  vpc_security_group_ids = [aws_security_group.privInstSG.id]
  subnet_id = aws_subnet.privSub.id
  depends_on = [aws_security_group.privInstSG]

  tags = {
    Name = var.privInstName
  }
}
```

## 6. Completion

Now, the Terraform code must be applied using `terraform apply`. After its completion, all environment will be available on the cloud. Just SSH into the bastion host and, from there only, one may SSH into the private instance.

A huge shout out to [@1Vidz1](https://github.com/1Vidz1), who developed this [on his own repo](https://github.com/1Vidz1/AWS-Terraform-Environments/) and was my pair-debugging pal - the last two sections are pretty much on him. Obrigado! Another one to the mentor of this project, [@tseideltrc](https://github.com/tseideltrc): bifanas no prato and Pedro's finest to you both! Vielen danke!

P.S.: Thanks to [@pdoerning](https://github.com/pdoerning) for the heads-up with adding Terraform state files on .gitignore!
