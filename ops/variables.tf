# Variável para o CIDR block da VPC. Será usada para definir o intervalo de IPs da rede.
variable "vpc_cidr_block" {
  description = "Bloco CIDR da VPC"
  type        = string
}

# Variável para o ARN do listener do ALB, passada entre módulos.
variable "alb_listener_arn" {
  description = "ARN do Listener do ALB"
  type        = string
}
