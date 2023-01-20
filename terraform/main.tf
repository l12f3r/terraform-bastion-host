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