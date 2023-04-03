
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