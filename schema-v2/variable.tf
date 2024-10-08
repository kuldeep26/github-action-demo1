variable "namespace" {
  default = "hello-world"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "knative_service_image" {
  default = "767397668494.dkr.ecr.us-east-1.amazonaws.com/ngnix-knative:1.2.1"
}

variable "rds_instance_name" {
  default = "testkcc"
}
