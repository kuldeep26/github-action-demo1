variable "namespace" {
  default = "hello-world"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "knative_service_image" {
  default = "891377368990.dkr.ecr.us-east-1.amazonaws.com/ngnix-knative:1.2.1"
}