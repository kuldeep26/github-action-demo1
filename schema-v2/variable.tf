variable "namespace" {
  default     = "helloworld"
}

variable "aws_region" {
  default     = "us-east-1"
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  default     = "975050194088.dkr.ecr.us-east-1.amazonaws.com"
}
