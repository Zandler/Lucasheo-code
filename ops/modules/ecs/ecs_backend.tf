# Criando o cluster ECS para o backend
resource "aws_ecs_cluster" "backend_cluster" {
  name = "backend-cluster"
}

# Definindo a task definition do ECS com Fargate, uma configuração sem servidor
resource "aws_ecs_task_definition" "backend_task" {
  family                   = "backend-task" # Nome da task
  network_mode             = "awsvpc"       # Usa o modo de rede 'awsvpc' para melhor isolamento
  requires_compatibilities = ["FARGATE"]    # Executando na plataforma Fargate (sem servidor)
  cpu                      = "256"          # Definindo 256 unidades de CPU
  memory                   = "512"          # Definindo 512 MB de memória

  # Definindo os containers para essa task
  container_definitions = <<DEFINITION
  [
    {
      "name": "backend-container",
      "image": "nginx", # Substitua pela imagem real do backend
      "cpu": 256,
      "memory": 512,
      "portMappings": [
        {
          "containerPort": 80,
          "hostPort": 80
        }
      ]
    }
  ]
  DEFINITION

  # Role que define permissões para a execução da tarefa ECS
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
}

# Criando o serviço ECS para gerenciar e executar a task no cluster
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"                        # Nome do serviço ECS
  cluster         = aws_ecs_cluster.backend_cluster.id       # Associando o cluster ECS criado
  task_definition = aws_ecs_task_definition.backend_task.arn # Usando a task definida anteriormente
  desired_count   = 2                                        # Número desejado de instâncias em execução

  # Configuração de rede para o serviço ECS
  network_configuration {
    subnets          = [aws_subnet.private.id]            # Usando subnets privadas para maior segurança
    security_groups  = [aws_security_group.backend_sg.id] # Aplicando o security group apropriado
    assign_public_ip = false                              # Não atribuir IP público ao container para mantê-lo privado
  }

  # Integração com o Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn # Apontando para o Target Group do backend
    container_name   = "backend-container"                # Nome do container a ser associado ao load balancer
    container_port   = 80                                 # Porta exposta pelo container
  }
}
