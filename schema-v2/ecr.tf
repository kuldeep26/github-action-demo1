resource "null_resource" "create_ecr_registry_secret" {
  provisioner "local-exec" {
    command = "bash ${path.module}/script/create-ecr-secret.sh ${var.aws_region} ${var.ecr_repository_url} ${var.namespace}"
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  default     = "593546282661.dkr.ecr.us-east-1.amazonaws.com"
}
