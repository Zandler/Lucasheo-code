
# Init code 

module "vpc" {
  source = "./vpc"

  vpc_name            = var.vpc_name
  cidr                = var.vpc_cidr
  vpc_private_subnets = var.private_subnets

  tags = var.tags

}

module "cloudfront" {
  source = "./cloudfront"

  acm_certificate = var.acm_certificate

  tags = var.tags
}
module "lambda" {

  source = "./lambda"

  tags = var.tags
}

