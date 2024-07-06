provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "eks-terraform-tfstate-demo"
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

provider "kubernetes" {
  host                   =  aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate =  base64decode(aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  =  data.aws_eks_cluster_auth.eks.token 
}
