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

resource "helm_release" "karpenter_crd" {
  depends_on = [aws_eks_cluster.cluster]
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter-crd"
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter-crd"
  version             = "v0.32.1"
  replace             = true
  force_update        = true

}

resource "helm_release" "karpenter" {
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name //create resource
  repository_password = data.aws_ecrpublic_authorization_token.token.password  //create resource
  chart               = "karpenter"
  version             = "v0.32.1"
  namespace           = "karpenter"
  create_namespace    = true

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.iam_role_arn
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "True"
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

  set {
    name  = "settings.featureGates.drift"
    value = "True"
  }

  set {
    name  = "tolerations[0].key"
    value = "system"
  }

  set {
    name  = "tolerations[0].value"
    value = "owned"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Equal"
  }

  set {
    name  = "tolerations[0].effect"
    value = "NoSchedule"
  }

}

# This module creates needed IAM resources which we will use when deploying Karpenter resources with Helm
module "karpenter" {
  version = "v20.17.2"
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = aws_eks_cluster.cluster.name
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEBSCSIDriverPolicy     = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  irsa_oidc_provider_arn          = data.aws_iam_openid_connect_provider.example.arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  create_iam_role   = false
  node_iam_role_arn = aws_iam_role.nodes.arn
}

data "aws_iam_openid_connect_provider" "example" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

