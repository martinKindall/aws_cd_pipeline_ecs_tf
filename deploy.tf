
resource "aws_codepipeline" "codepipeline" {
  name     = "tf-my-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = "codepipeline-eu-central-1-682409244870"
    type     = "S3"

    encryption_key {
      id   = "arn:aws:kms:eu-central-1:371417955885:key/5cbf962c-6244-4405-b582-010c99186f98"
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]
      namespace        = "SourceVariables"

      configuration = {
        ConnectionArn        = "arn:aws:codestar-connections:eu-central-1:371417955885:connection/e4345384-e5a6-453d-9814-c5bacfe4740a"
        FullRepositoryId     = "martinKindall/aws_code_deploy_example"
        BranchName           = "main"
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = true
      }
    }

    action {
      name             = "SpringImage"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["MyImage"]

      configuration = {
        RepositoryName = "spring_example"
        ImageTag = "latest"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["SourceArtifact", "MyImage"]
      version         = "1"

      configuration = {
        ApplicationName                = aws_codedeploy_app.my_spring_app.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.spring_group.deployment_group_name
        TaskDefinitionTemplateArtifact = "SourceArtifact"
        AppSpecTemplateArtifact        = "SourceArtifact"
        AppSpecTemplatePath            = "appspec.yml"
        TaskDefinitionTemplatePath     = "taskdef.json"
        Image1ArtifactName             = "MyImage"
        Image1ContainerName            = "IMAGE1_NAME"
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name               = "tf-codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_pipeline.json
}

data "aws_iam_policy_document" "assume_role_pipeline" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}

data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = ["*"]

    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "elasticloadbalancing:*",
      "ecs:*",
      "cloudwatch:*",
      "ecr:DescribeImages",
      "codestar-connections:UseConnection"
    ]
    resources = ["*"]
  }
}

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
  assume_role_policy = data.aws_iam_policy_document.assume_role_codedeploy.json

  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"]
}

data "aws_iam_policy_document" "assume_role_codedeploy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}