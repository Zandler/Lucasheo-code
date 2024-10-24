variable "aws_region" {
  default = "us-east-1"
}

variable "domain_name" {
  description = "The domain name for which the certificate should be issued"
  type        = string
  default     = "terraform-aws-modules.modules.tf"
}