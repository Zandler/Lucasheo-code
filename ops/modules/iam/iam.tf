# Definindo a role IAM para execução de tarefas ECS
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  # Política para permitir que o serviço ECS assuma essa role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com" # Serviço ECS Tasks
        }
      }
    ]
  })
}

# Anexando a política de execução de tarefas do ECS à role criada
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

  # Utilizando o nome da role diretamente
  role = aws_iam_role.ecs_task_execution_role.name
}


