# Gerando uma senha segura usando o Secrets Manager (opcional)
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "rds-credentials"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = "password-segura" # Aqui você poderia usar um random_password para gerar uma senha aleatória segura
  })
}

# Criando o grupo de subnets do RDS
resource "aws_db_subnet_group" "main" {
  name       = "mydb_subnet_group"
  subnet_ids = [aws_subnet.private.id] # Subnet privada para garantir que o banco de dados não está exposto publicamente
}

# Definindo o Security Group para o backend com regras restritas de acesso
resource "aws_security_group" "backend_sg" {
  name        = "backend_sg"
  description = "Allow access to MySQL from backend instances"
  vpc_id      = aws_vpc.main.id

  # Permitir acesso ao banco de dados apenas da aplicação (portas restritas)
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id] # Apenas o security group do app pode acessar
  }

  # Saída irrestrita (necessária para permitir a comunicação de saída)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Criando a instância de banco de dados MySQL com as melhores práticas de segurança
resource "aws_db_instance" "mydb" {
  allocated_storage = 20
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"

  # Nome do banco de dados
  db_name = "teste-lucas"

  # Recuperando as credenciais do Secrets Manager
  username = jsondecode(aws_secretsmanager_secret_version.db_password.secret_string).username
  password = jsondecode(aws_secretsmanager_secret_version.db_password.secret_string).password

  # Parâmetros do grupo do MySQL 8.0
  parameter_group_name = "default.mysql8.0"

  # Acesso público desabilitado
  publicly_accessible = false

  # Pular snapshot final para evitar custos desnecessários
  skip_final_snapshot = true

  # Usar o Security Group do backend para restringir o acesso ao banco de dados
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  # Usar a Subnet privada configurada no grupo de subnets
  db_subnet_group_name = aws_db_subnet_group.main.name

  # Habilitando a criptografia do banco de dados
  storage_encrypted = true

  # Habilitando logs no CloudWatch (monitoramento de queries lentas e auditoria)
  enabled_cloudwatch_logs_exports = ["error", "slowquery", "audit"]

  # Usando Multi-AZ para alta disponibilidade
  multi_az = true
}

# Definindo o random_password (opcional) para garantir uma senha forte
resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# Usando o random_password para garantir uma senha segura via Secrets Manager (opcional)
resource "aws_secretsmanager_secret_version" "db_password_random" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = random_password.rds_password.result
  })
}

