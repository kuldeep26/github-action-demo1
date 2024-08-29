resource "null_resource" "create_ecr_registry_secret" {
  provisioner "local-exec" {
    command = <<EOT
      bash ${path.module}/script/create-ecr-secret.sh "${var.aws_region}" "${var.ecr_repository_url}" "${var.namespace}"
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  default     = "590184049425.dkr.ecr.us-east-1.amazonaws.com"
}
