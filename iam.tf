
resource "aws_iam_role" "ecs_task_executor" {
  name = "my_ecs_task_executor_role"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}