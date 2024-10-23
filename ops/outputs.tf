# Exemplo de output que retorna o ID da VPC
output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

# Output que retorna o nome DNS do ALB, que pode ser usado para acessar a aplicação
output "alb_dns" {
  description = "Nome DNS do ALB"
  value       = aws_lb.application_lb.dns_name
}
