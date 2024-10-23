provider "aws" {
  region = local.region

}

data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-east-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    name    = local.name
    lab     = lucasheo
    
  }
}


# VPC

module "vpc_example_simple" {
  source  = "terraform-aws-modules/vpc/aws//examples/simple"
  version = "5.14.0"

  name = local.name
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]

  tags = local.tags

}

