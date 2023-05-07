## Continuous Deployment pipeline for ECS using ECR, CodePipeline and CodeDeploy

Make sure to fill every variable from __variables.tf__ according to your environment.

Note that the repository [martinKindall/aws_code_deploy_example](https://github.com/martinKindall/aws_code_deploy_example) is already part of this pipeline: it contains the necessary files for CodeDeploy and ECS to deploy a new task. You can use another repository with the proper _appspec.yml_ and _taskdef.json_ files.