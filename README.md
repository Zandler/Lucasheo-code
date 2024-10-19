Estrutura da Documentação

Visão Geral da Stack

Objetivo: Descrever o propósito da infraestrutura e os componentes principais.
Componentes da Stack:
Backend: API REST escalável
Frontend: Site estático com consumo da API
Banco de dados: Acesso restrito às aplicações
Load balancer: Balanceamento de tráfego entre as aplicações
Resolução de DNS: Usando o mesmo domínio com paths diferentes
Tecnologias Utilizadas: Terraform, ECS Fargate, S3, CloudFront, RDS, Route 53, ALB
Configuração da Rede (VPC e Subnets)

Arquivo: vpc.tf
Descrição: Este arquivo define a Virtual Private Cloud (VPC), subnets públicas e privadas e o internet gateway.
Fatores Importantes:
VPC: Cuidado ao definir o CIDR block da VPC para evitar sobreposição com outras redes.
Subnets: Subnets públicas para serviços acessíveis pela internet, como o frontend e ALB, e subnets privadas para o backend e banco de dados para garantir segurança.
Internet Gateway: Necessário para fornecer acesso à internet às subnets públicas.
Grupos de Segurança (Security Groups)

Arquivo: security_groups.tf
Descrição: Define os Security Groups (SGs) que controlam o tráfego de entrada e saída para cada serviço.
Fatores Importantes:
Segurança: O SG do backend só deve permitir tráfego proveniente do ALB e não diretamente da internet.
Frontend: Deve permitir tráfego HTTP/HTTPS da internet.
Banco de Dados: Deve ser acessível apenas pelo backend e não pela internet.
Configuração do ECS Fargate para o Backend

Arquivo: ecs_backend.tf
Descrição: Define a cluster do ECS, a task definition e o serviço para rodar o backend como containers escaláveis.
Fatores Importantes:
Fargate: Serverless e gerenciado pela AWS, facilitando a escalabilidade sem necessidade de gerenciar servidores.
Task Definition: Configurar as imagens de containers corretamente, definir portas e recursos como CPU e memória.
Auto Scaling: Certifique-se de definir regras de escalabilidade automática para garantir que o backend possa lidar com picos de tráfego.
S3 e CloudFront para o Frontend

Arquivo: s3_cloudfront.tf
Descrição: Configura o bucket do S3 para hospedar o frontend e distribui o conteúdo através do CloudFront, garantindo menor latência e alta disponibilidade.
Fatores Importantes:
S3: Usado para hospedar o site estático. O bucket deve ter políticas adequadas para permitir o acesso público seguro.
CloudFront: Configurado como CDN, melhora o desempenho global do site com caching e suporte a HTTPS.
Banco de Dados RDS

Arquivo: rds.tf
Descrição: Configura o banco de dados relacional RDS (MySQL/PostgreSQL), criando um banco gerenciado e seguro com backups automáticos.
Fatores Importantes:
Segurança: O RDS deve ser provisionado em subnets privadas e protegido por SG que só permita tráfego do backend.
Backups: Certifique-se de que as configurações de backup e retenção estejam habilitadas para segurança de dados.
Load Balancer e Route 53

Arquivo: alb_route53.tf
Descrição: Define o Application Load Balancer (ALB) para distribuir o tráfego entre o frontend e o backend, com regras baseadas em path (/frontend e /backend), além de configurar a resolução DNS via Route 53.
Fatores Importantes:
ALB: Configure corretamente as regras de roteamento para garantir que o frontend e backend compartilhem o mesmo domínio.
Route 53: Configure corretamente os registros DNS para garantir que as aplicações sejam acessíveis pelos nomes de domínio configurados.
IAM Roles para ECS

Arquivo: iam.tf
Descrição: Define as permissões IAM necessárias para que o ECS possa executar tarefas e interagir com outros serviços da AWS.
Fatores Importantes:
Segurança: As permissões devem ser mínimas, concedendo apenas os acessos necessários para o serviço executar suas funções.
Passos para Implementação
Configuração da VPC e Rede

Inicialize o Terraform e aplique o arquivo vpc.tf para criar a VPC e subnets.
Certifique-se de que a rede está configurada corretamente com o internet gateway e roteamento adequado.
Configuração dos Security Groups

Aplique o arquivo security_groups.tf para criar os Security Groups necessários, garantindo que as permissões de tráfego estejam corretas.
Criação do Backend no ECS Fargate

Aplique o arquivo ecs_backend.tf para configurar a cluster ECS, task definition e serviços para o backend.
Configure o Auto Scaling baseado em métricas como CPU e memória.
Configuração do Frontend com S3 e CloudFront

Aplique o arquivo s3_cloudfront.tf para criar o bucket S3 e a distribuição do CloudFront.
Teste se o frontend está sendo servido corretamente via CloudFront.
Configuração do Banco de Dados RDS

Aplique o arquivo rds.tf para provisionar o banco de dados.
Teste a conectividade entre o backend e o banco, garantindo que o banco esteja acessível apenas pelo backend.
Configuração do Load Balancer e Route 53

Aplique o arquivo alb_route53.tf para configurar o ALB e Route 53.
Teste as regras de roteamento para garantir que /frontend e /backend funcionem conforme esperado.
Configuração de IAM para ECS

Aplique o arquivo iam.tf para criar os roles necessários para a execução das tasks no ECS.
Considerações Finais
Segurança: Garanta que todos os recursos sensíveis, como o banco de dados, estejam em subnets privadas e protegidos por regras de firewall rigorosas.
Escalabilidade: Configure Auto Scaling tanto no ECS quanto no RDS para que os serviços possam lidar com variações de carga.
Custo: Avalie os custos periódicos dos serviços utilizados, como o CloudFront, ALB, ECS e RDS, para otimizar conforme o uso.
