
# Define o provedor AWS e a região onde a infraestrutura será criada
provider "aws" {
  region = "us-east-1"
}

# Módulo para criação da VPC, que vai criar as subnets públicas e privadas, internet gateway e NAT gateway
module "vpc" {
  source = "./modules/vpc"
  # Variáveis da VPC podem ser passadas aqui, como o CIDR block
  # Exemplo: cidr_block = "10.0.0.0/16"
}

# Módulo para grupos de segurança, que irão controlar o tráfego de entrada e saída para os recursos
module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id  # Passa o ID da VPC do módulo VPC para os grupos de segurança
}

# Módulo para o Application Load Balancer (ALB) e configuração do Route 53
module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.vpc_id  # Passa o ID da VPC para o ALB
}

# Módulo para o backend ECS. Este módulo vai criar os target groups e listeners necessários para o ECS.
module "ecs" {
  source = "./modules/ecs"
  vpc_id           = module.vpc.vpc_id          # ID da VPC é necessário para o ECS
  alb_listener_arn = module.alb.listener_arn    # O ARN do listener do ALB será usado aqui
}

# Módulo para roles e políticas do IAM, usadas para controle de permissões
module "iam" {
  source = "./modules/iam"
}

# Módulo para provisionamento do banco de dados RDS
module "rds" {
  source = "./modules/rds"
  vpc_id = module.vpc.vpc_id  # Passa o ID da VPC para o RDS
}

# Módulo para configurar o S3 e o CloudFront, permitindo servir conteúdo estático
module "s3_cloudfront" {
  source = "./modules/s3_cloudfront"
}

# Exemplo de output do DNS do ALB
output "alb_dns_name" {
  description = "Nome DNS do ALB"
  value       = module.alb.alb_dns
}
