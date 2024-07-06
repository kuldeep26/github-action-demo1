data "aws_iam_openid_connect_provider" "example" {
  url = aws_eks_cluster.cluster.issuer
}