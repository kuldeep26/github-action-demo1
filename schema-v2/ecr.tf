# resource "null_resource" "create_ecr_registry_secret" {
#   provisioner "local-exec" {
#     command = "bash ${path.module}/script/create-ecr-secret.sh ${var.aws_region} ${var.ecr_repository_url} ${var.namespace}"
#   }

#   triggers = {
#     always_run = "${timestamp()}"
#   }
# }

variable "ecr_repository_url" {
  description = "The URL of the ECR repository"
  default     = "654654326569.dkr.ecr.us-east-1.amazonaws.com"
}

///////// Test ///////////


# Fetch the ECR repository information
data "aws_ecr_repository" "example" {
  name = "ngnix-knative"
}

# Fetch image information using the image tag (e.g., "latest")
data "aws_ecr_image" "example" {
  repository_name = data.aws_ecr_repository.example.name
  image_tag       = "1.2.1" # You must specify the correct image tag that exists in the repository
}

# Output the image digest
output "ecr_image_digest" {
  value = data.aws_ecr_image.example.image_digest
}
