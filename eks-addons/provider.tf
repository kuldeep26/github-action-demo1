provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "eks-terraform-tfstate-demo-1"
    key    = "services/eks-addons/terraform.tfstate"
    region = "us-east-1"
  }
}

terraform {
  required_version = "1.5.5"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.6"
    }
    http = {
      source = "hashicorp/http"
      #version = "2.1.0"
      #version = "~> 2.1"
      version = "~> 3.3"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.platform-compute-cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.platform-compute-cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.platform-compute-cluster.name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.platform-compute-cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.platform-compute-cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.platform-compute-cluster.name]
      command     = "aws"
    }
  }
}