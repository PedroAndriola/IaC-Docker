module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
    name = var.ambiente
    container_insights  =  true
    capacity_providers  = ["FARGATE"]
    default_capacity_provider_strategy = [
        {capacity_provider = "FARGATE"}
    ] 
    
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

resource "aws_ecs_service" "django-API" {
  name            = "django-API"
  cluster         = module.ecs.ecs_cluster_id
  task_definition = aws_ecs_task_definition.django-API.arn
  desired_count   = 3


  load_balancer {
    target_group_arn = aws_lb_target_group.alvo.arn
    container_name   = var.ambiente
    container_port   = 8000
  }



  network_configuration {
    subnets = module.vpc.private_subnets
    security_groups = [aws_security_group.private.id]
 }
}

capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight = 1
}