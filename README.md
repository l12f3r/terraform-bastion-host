# terraform-bastion-host

[@l12f3r](https://github.com/l12f3r) here, once again, to share how to create a bastion host (or "jump host", depending on jargon) on an AWS Virtual Private Cloud, using Terraform. This can be considered a beginner exercise for those interested in learning a bit more on networking, infrastructure as code and cloud computing.

For those who know me from the [lizferLinux exercise](https://github.com/l12f3r/lizferLinux), buckle your seatbelts because this is a new challenge. If it's your first time around, you can route back to it and take a look how I usually document my own learning and share it on Github.

I'll try to provision everything (network, instances, security) using code and command line. For best practices, I'll provision everything using a `variables.tf` file to separate the variables from the main infrastructure code, and a `parameters.tfvars` file - that way, infrastructure parameters (such as instance type, region, and tags) can vary depending on preference (or necessity). And, of course, avoid hardcoding.

## 1. Create a VPC

Upon provisioning the Virtual Private Network (VPC), one may specify just some instance details and have the VPC automatically provisioned with default values. However, such architecture would lack on autonomy. The following lines of code contain some fundamental parameters for setting up two subnets: a public one, for the bastion host, and another private one for the instances that will receive the bastion host access. Descriptions on each parameter are defined on the `variables.tf` excerpt.

```terraform
# main.tf
resource "aws_vpc" "main" {
  cidr_block = "var.cidr_block"
}
```

```terraform
# variables.tf
variable "cidr_block" {
  type = string
  description = "CIDR block of the VPN"
}
```

## 2. create Internet Gateway
## 3. create subnets (public and private)
## 4. create route tables
### 4.a point public route table to Internet Gateway
### 4.b configure NAT gateway
## 5. create public (w/ public IP) and private instances (w/ security groups) in respective public and private subnets
