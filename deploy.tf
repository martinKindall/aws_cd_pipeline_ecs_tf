
resource "aws_codedeploy_app" "my_spring_app" {
  compute_platform = "ECS"
  name             = "spring_app"
}

resource "aws_codedeploy_deployment_group" "spring_group" {
  app_name               = aws_codedeploy_app.my_spring_app.name
  deployment_group_name  = "ECSDeployment"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codeDeploy.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.my_cluster.name
    service_name = aws_ecs_service.my_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.front_end.arn]
      }

      target_group {
        name = aws_lb_target_group.my_Tg.name
      }

      target_group {
        name = aws_lb_target_group.my_Tg_2.name
      }
    }
  }
}

resource "aws_iam_role" "codeDeploy" {
  name               = "codeDeployEcs"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"]
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}