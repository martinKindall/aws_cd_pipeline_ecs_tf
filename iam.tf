
# resource "aws_iam_role" "ecs_service_role" {
#   name = "my_ecs_service_role"

#   assume_role_policy = data.aws_iam_policy_document.ecs_service_trust.json

#   managed_policy_arns = ["arn:aws:iam::aws:policy/aws-service-role/AmazonECSServiceRolePolicy"]
# }

# data "aws_iam_policy_document" "ecs_service_trust" {
#   statement {
#     actions = ["sts:AssumeRole"]

#     principals {
#       type        = "Service"
#       identifiers = ["ecs.amazonaws.com"]
#     }
#   }
# }