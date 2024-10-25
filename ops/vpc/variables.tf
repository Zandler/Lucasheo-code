
variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "AWS default region"
}

variable "vpc_name" {}
variable "cidr" {}
variable "vpc_private_subnets" {}
variable "tags" {}

