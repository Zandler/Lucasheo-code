# Provider variable 

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# VPC Variables

variable "vpc_name" {
  type    = string
  default = "aws-vpc-"
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/22"
}

variable "private_subnets" {
  type    = list(any)
  default = ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24"]
}

# Cloudfront Variable 
# This cam be passed with variable in pipeline for security reasons
# ex. terraform apply -ver "acm_certificate="arn-example"

variable "acm_certificate" {}
variable "tags" {
  type = map(string)
  default = {
    environemnt = "dev"
    owner       = "localiza-group"
    start-stop  = "true"
  }
}
