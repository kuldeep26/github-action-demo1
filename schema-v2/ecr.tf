data "external" "create_ecr_registry_secret" {
  program = ["bash", "${path.module}/script/create-ecr-secret.sh"]

  query = {
    aws_region         = var.aws_region
    ecr_repository_url = var.ecr_repository_url
    namespace          = var.namespace
  }
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  default     = "590184049425.dkr.ecr.us-east-1.amazonaws.com"
}
