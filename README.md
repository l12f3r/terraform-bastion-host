# bastion-host

[@l12f3r](https://github.com/l12f3r) here, once again, to share how to create a bastion host (or "jump host", depending on jargon) on an AWS Virtual Private Cloud, using Terraform. This can be considered a beginner exercise for those interested in learning a bit more on networking, infrastructure as code and cloud computing.

For those who know me from the [lizferLinux exercise](https://github.com/l12f3r/lizferLinux), buckle your seatbelts because this is a new challenge. If it's your first time around, you can route back to it and take a look how I usually document my own learning and share it on Github.

## 1. Create a VPC

Upon provisioning the Virtual Private Network (VPC), we must define

## 2. create Internet Gateway
## 3. create subnets (public and private)
## 4. create route tables
### 4.a point public route table to Internet Gateway
### 4.b configure NAT gateway
## 5. create public (w/ public IP) and private instances (w/ security groups) in respective public and private subnets
