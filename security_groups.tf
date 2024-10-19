# Grupo de segurança para o frontend (aplicação web ou load balancer)
resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.main.id # Usar a VPC principal

  # Regras de entrada (ingress)
  ingress {
    from_port   = 80 # Permitir tráfego HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite tráfego de qualquer origem, HTTP público (considere limitar a fontes conhecidas)
  }

  ingress {
    from_port   = 443 # Permitir tráfego HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Permite tráfego HTTPS de qualquer origem (considere limitar para fontes específicas)
  }

  # Regras de saída (egress)
  egress {
    from_port   = 0 # Permitir todo o tráfego de saída
    to_port     = 0
    protocol    = "-1"          # -1 indica todos os protocolos
    cidr_blocks = ["0.0.0.0/0"] # Permitir saída para qualquer destino
  }
}

# Grupo de segurança para o backend (servidor de aplicação, banco de dados, etc.)
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main.id # Usar a mesma VPC para o backend

  # Regras de entrada (ingress)
  ingress {
    from_port   = 80 # Permitir tráfego HTTP
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.frontend_sg.cidr_block] # Permitir tráfego apenas do frontend (melhor prática)
  }

  ingress {
    from_port   = 443 # Permitir tráfego HTTPS
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_security_group.frontend_sg.cidr_block] # Permitir tráfego HTTPS apenas do frontend
  }

  # Regras de saída (egress)
  egress {
    from_port   = 0 # Permitir todo o tráfego de saída
    to_port     = 0
    protocol    = "-1"          # -1 indica todos os protocolos
    cidr_blocks = ["0.0.0.0/0"] # Permitir saída para qualquer destino (pode ser ajustado conforme necessário)
  }
}
