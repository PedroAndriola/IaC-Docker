module "prod" {
    source = "../../infra"

    nome_repositorio = "producao"
    cargoIAM = "producao"

    output "ip_alb" {
        value = "module.prod.ip"
        ambiente = producao
    }
}

resource "aws_ecs_task_definition" "django-api" {
  family                   = "django-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.cargo.arn
  container_definitions    = jsonencode( 
[
  {
    "name"= var.ambiente,
    "image"= "mcr.microsoft.com/windows/servercore/iis",
    "cpu"= 256,
    "memory"= 512,
    "essential"= true
    "portMappings"= [
        {
            "containerPort"= 8000
            "hostPort"= 8000
        }
    ]
  }
])
}