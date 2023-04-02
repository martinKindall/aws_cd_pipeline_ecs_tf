
resource "aws_codedeploy_app" "my_spring_app" {
  compute_platform = "ECS"
  name             = "spring_app"
}

