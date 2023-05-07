
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "repository_name" {
  description = "Name of the ECR repository for the spring app"
  type = string
  default = "spring_example"
}

variable "codestar_connection_arn" {
  description = "ARN of codestar connection with privileges to the FullRepositoryId specified in codepipeline. The arn looks like this arn:aws:codestar-connections:eu-central-1:<ACCOUNT_ID>:connection/<CONNECTION_ID>"
  type = string
}

variable "git_repository_name" {
  description = "Repository name which contains the appspec.yml and taskdef.json. Example: martinKindall/aws_code_deploy_example"
  type = string
}

variable "codepipeline_bucket" {
  description = "S3 bucket name for codepipeline"
  type = string
}

variable "codepipeline_bucket_encryption_key_arn" {
  description = "ARN of the encryption key associated with the buckte. Example: arn:aws:kms:eu-central-1:<ACCOUNT_ID>:key/<KEY_ID>"
  type = string
}