data "aws_ecr_authorization_token" "ecr" {}

resource "kubernetes_secret" "ecr_registry_secret" {
  metadata {
    name      = "ecr-registry-secret"
    namespace = var.namespace
  }

  data = {
    ".dockerconfigjson" = base64encode(jsonencode({
      auths = {
        "${var.ecr_repository_url}" = {
          "username" = "AWS",
          "password" = data.aws_ecr_authorization_token.ecr.authorization_token,
          "email" = "none"
        }
      }
    }))
  }

  type = "kubernetes.io/dockerconfigjson"
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  default     = "637423192029.dkr.ecr.us-east-1.amazonaws.com"
}
