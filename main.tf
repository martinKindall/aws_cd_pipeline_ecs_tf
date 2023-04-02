
provider "aws" {
  region = var.aws_region
}

resource "aws_ecs_cluster" "my_cluster" {
  name = "exampleClusterTf"
}

resource "aws_ecs_service" "my_service" {
  name            = "springApp"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = "arn:aws:ecs:eu-central-1:371417955885:task-definition/spring_app"
  desired_count   = 0
  depends_on = [
    aws_lb.myAlb
  ]

  scheduling_strategy = "REPLICA"
  launch_type         = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.my_Tg.arn
    container_name   = "spring_ex"
    container_port   = 80
  }

  network_configuration {
    subnets         = data.aws_subnets.mySubnets.ids
    security_groups = [aws_security_group.spring_app.id]
    assign_public_ip = true
  }
}