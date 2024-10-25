
###
# AWS infra deployment
###

# Get aws info

data "aws_availability_zones" "this" {}

locals {
  azs = slice(data.aws_availability_zones.this.names, 0, 3)

}

###
# VPC Module 


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = var.vpc_name
  cidr = var.cidr

  azs             = local.azs
  private_subnets = var.vpc_private_subnets

  tags = var.tags
}
