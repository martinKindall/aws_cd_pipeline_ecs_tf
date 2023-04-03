resource "aws_cloudwatch_event_rule" "ecr" {
  name        = "trigger-ecr-event-codepipeline"
  description = "Triggers Codepipeline"
  role_arn    = aws_iam_role.events_role.arn

  event_pattern = jsonencode({
    detail-type = [
      "ECR Image Action"
    ]
    detail = {
      action-type     = ["PUSH"]
      image-tag       = ["latest"]
      repository-name = ["spring_example"]
      result          = ["SUCCESS"]
    }
  })
}

resource "aws_cloudwatch_event_target" "codepipeline" {
  rule      = aws_cloudwatch_event_rule.ecr.name
  target_id = "SendToCodePipelineSpringApp"
  arn       = aws_codepipeline.codepipeline.arn
  role_arn  = aws_iam_role.events_role.arn
}

resource "aws_iam_role" "events_role" {
  name               = "tf-events-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_events.json
}

data "aws_iam_policy_document" "assume_role_events" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_event_policy" {
  name   = "cloudwatch_event_policy"
  role   = aws_iam_role.events_role.id
  policy = data.aws_iam_policy_document.cloudwatch_event_policy.json
}

data "aws_iam_policy_document" "cloudwatch_event_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codepipeline:StartPipelineExecution"
    ]
    resources = [aws_codepipeline.codepipeline.arn]
  }
}