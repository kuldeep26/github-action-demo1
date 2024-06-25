provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "eks-terraform-tfstate-demo-1"
    key    = "services/eks/terraform.tfstate"
    region = "us-east-1"
  }
}

terraform {
  required_version = "1.5.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6"
    }
  }
}
