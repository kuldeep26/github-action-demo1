resource "null_resource" "create_ecr_registry_secret" {
  provisioner "local-exec" {
    command = <<EOT
    # Fetch ECR login password
    ecr_password=$(aws ecr get-login-password --region ${var.aws_region})

    # Create the Kubernetes secret
    kubectl create secret docker-registry ecr-registry-secret \
      --docker-server=${var.ecr_repository_url} \
      --docker-username=AWS \
      --docker-password="${ecr_password}" \
      --namespace ${var.namespace}
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  default     = "637423192029.dkr.ecr.us-east-1.amazonaws.com"
}
