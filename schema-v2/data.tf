data "aws_eks_cluster" "platform-compute-cluster" {
  name = "demo"
}

##

data "tls_certificate" "eks-cluster-certificate" {
  url = data.aws_eks_cluster.platform-compute-cluster.identity[0].oidc[0].issuer
}

data "aws_iam_openid_connect_provider" "eks-cluster-openid-provider" {
  url = data.tls_certificate.eks-cluster-certificate.url
}

data "aws_secretsmanager_secret" "rds_password_secret" {
  name = "rds-password"
}