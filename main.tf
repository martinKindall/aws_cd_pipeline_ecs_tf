
provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "my_cluster" {
  name = "exampleClusterTf"
}

resource "aws_ecs_service" "my_service" {
  name            = "springApp"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = format("arn:aws:ecs:%s:%s:task-definition/spring_app", var.aws_region, data.aws_caller_identity.current.account_id)
  desired_count   = 1

  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }

  scheduling_strategy = "REPLICA"
  launch_type         = "FARGATE"
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.my_Tg.arn
    container_name   = "spring_ex"
    container_port   = 80
  }

  network_configuration {
    subnets          = data.aws_subnets.mySubnets.ids
    security_groups  = [aws_security_group.spring_app.id]
    assign_public_ip = true
  }
}