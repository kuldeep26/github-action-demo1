provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.cluster.id]
      command     = "aws"
    }
  }
}

data "aws_availability_zones" "available" {}

# This data source can only be used in the us-east-1 region.
data "aws_ecrpublic_authorization_token" "token" {
}

resource "helm_release" "karpenter" {
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name //create resource
  repository_password = data.aws_ecrpublic_authorization_token.token.password  //create resource
  chart               = "karpenter"
  version             = "0.37.0"
  namespace           = "karpenter"
  create_namespace    = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "clusterName"
    value = aws_eks_cluster.cluster.name
  }

  set {
    name  = "clusterEndpoint"
    value = aws_eks_cluster.cluster.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  # We will be using SQS queue name which we created previously with Karpenter module
  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }

}

# This module creates needed IAM resources which we will use when deploying Karpenter resources with Helm
module "karpenter" {
  version = "v19.16.0"
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks_cluster.cluster_name

  irsa_oidc_provider_arn          = data.aws_iam_openid_connect_provider.example.arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role = false
  iam_role_arn    = aws_iam_role.nodes.arn

  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

}

data "aws_iam_openid_connect_provider" "example" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

