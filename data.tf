# data "aws_iam_openid_connect_provider" "example" {
#   url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
# }

data "aws_caller_identity" "current" {}