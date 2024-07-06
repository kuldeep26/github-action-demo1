data "aws_iam_openid_connect_provider" "example" {
  arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/${aws_eks_cluster.cluster.id}"
}

data "aws_caller_identity" "current" {}