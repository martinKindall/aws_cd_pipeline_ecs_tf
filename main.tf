
provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "exampleClusterTf"
}

resource "aws_ecs_task_definition" "service" {
  family                   = "springApp"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_task_executor.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      "name" : "spring_ex",
      "image" : "371417955885.dkr.ecr.eu-central-1.amazonaws.com/spring_example",
      "cpu" : 0,
      "portMappings" : [
        {
          "name" : "spring_ex-80-tcp",
          "containerPort" : 80,
          "hostPort" : 80,
          "protocol" : "tcp",
          "appProtocol" : "http"
        }
      ],
      "essential" : true,
      "environment" : [
        {
          "name" : "SPRING_PROFILES_ACTIVE",
          "value" : "production"
        }
      ],
      "mountPoints" : [],
      "volumesFrom" : [],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-create-group" : "true",
          "awslogs-group" : "/ecs/spring_app",
          "awslogs-region" : "eu-central-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}