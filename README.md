# terraform-bastion-host

[@l12f3r](https://github.com/l12f3r) here, once again, to share how to create a bastion host (or "jump host", depending on jargon) on an AWS Virtual Private Cloud, using Terraform. This can be considered a beginner exercise for those interested in learning a bit more on networking, infrastructure as code and cloud computing.

For those who know me from the [lizferLinux exercise](https://github.com/l12f3r/lizferLinux), buckle your seatbelts because this is a new challenge. If it's your first time around, you can route back to it and take a look how I usually document my own learning and share it on Github.

I'll try to provision everything (network, instances, security) using code and command line. For best practices, I'll provision everything using a `variables.tf` file to separate variables from the main infrastructure code (and to describe what is the use of each parameter), and a `parameters.tfvars` file - that way, infrastructure parameters (such as instance type, region, and tags) can vary depending on preference (or necessity). And, of course, avoid hardcoding.

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

Upon provisioning the Virtual Private Network (VPC), one may specify just some instance details and have the VPC automatically provisioned with default values. However, such architecture would lack on autonomy. The following lines of code contain some fundamental parameters for setting up two subnets: a public one, for the bastion host, and another private one for the instances that will receive the bastion host access.

```terraform
# main.tf
resource "aws_vpc" var.vpcName {
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

## 3. create Internet Gateway
## 4. create subnets (public and private)
## 5. create route tables
### 5.a point public route table to Internet Gateway
### 5.b configure NAT gateway
## 6. create public (w/ public IP) and private instances (w/ security groups) in respective public and private subnets
