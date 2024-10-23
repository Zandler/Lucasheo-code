# Criando o certificado SSL para o domínio frontend usando DNS validation
resource "aws_acm_certificate" "frontend_cert" {
  domain_name       = "frontend.example.com"
  validation_method = "DNS" # Usando DNS para validação automática
}

# Criando um registro DNS para validar o certificado SSL no Route53
resource "aws_route53_record" "frontend_cert_validation" {
  name    = aws_acm_certificate.frontend_cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.frontend_cert.domain_validation_options[0].resource_record_type
  zone_id = aws_route53_zone.main.zone_id
  records = [aws_acm_certificate.frontend_cert.domain_validation_options[0].resource_record_value]
  ttl     = 60 # Tempo para que o DNS seja propagado
}

# Criando o Application Load Balancer (ALB) público
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  internal           = false                               # O ALB é público
  load_balancer_type = "application"                       # Tipo de load balancer: 'application'
  security_groups    = [aws_security_group.frontend_sg.id] # Associando o grupo de segurança
  subnets            = [aws_subnet.public.id]              # Usando as subnets públicas
}

# Criando o Target Group do backend (onde o tráfego será direcionado)
resource "aws_lb_target_group" "backend_tg" {
  name     = "backend-tg"
  port     = 80 # O backend está ouvindo na porta 80 (HTTP)
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id # Identificação da VPC onde o backend está localizado
}

# Criando o listener para HTTPS no ALB
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 443
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-2016-08"           # Política de segurança SSL recomendada
  certificate_arn = aws_acm_certificate.frontend_cert.arn # Usar o certificado SSL

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn # O tráfego será redirecionado para o Target Group backend
  }
}

# Criando o listener para HTTP (opcional, redireciona para HTTPS)
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol    = "HTTPS"
      port        = "443"
      status_code = "HTTP_301"
    }
  }
}

# Criando o grupo de segurança para o ALB (frontend)
resource "aws_security_group" "frontend_sg" {
  name        = "frontend-sg"
  description = "Allow inbound HTTP and HTTPS traffic to ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir tráfego HTTP de qualquer IP (considere restringir para IPs conhecidos)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permitir tráfego HTTPS de qualquer IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Permitir todo o tráfego de saída
  }
}

# Criando uma zona Route53 para gerenciar o domínio
resource "aws_route53_zone" "main" {
  name = "example.com" # Substituir pelo seu domínio
}

# Criando um registro DNS para o frontend no Route53
resource "aws_route53_record" "frontend" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "frontend.example.com" # Nome do subdomínio para o frontend
  type    = "A"                    # Tipo de registro A (endereço IPv4)

  alias {
    name                   = aws_lb.application_lb.dns_name # Usar o DNS do ALB como alias
    zone_id                = aws_lb.application_lb.zone_id  # Usar a zone_id do ALB
    evaluate_target_health = true                           # Avaliar a saúde do alvo, útil para alta disponibilidade
  }
}

# Criando um registro DNS para o backend no Route53
resource "aws_route53_record" "backend" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "backend.example.com" # Nome do subdomínio para o backend
  type    = "A"                   # Tipo de registro A (endereço IPv4)

  alias {
    name                   = aws_lb.application_lb.dns_name # Usar o DNS do ALB como alias
    zone_id                = aws_lb.application_lb.zone_id  # Usar a zone_id do ALB
    evaluate_target_health = true                           # Avaliar a saúde do alvo, útil para alta disponibilidade
  }
}
