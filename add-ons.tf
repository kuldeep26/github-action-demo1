resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "vpc-cni"
  addon_version = "v1.18.2-eksbuild.1"
  #  resolve_conflicts_on_update = "PRESERVE"
  service_account_role_arn = aws_iam_role.vpc_cni.arn
}

# resource "aws_eks_addon" "kube-proxy" {
#   cluster_name  = aws_eks_cluster.cluster.name
#   addon_name    = "kube-proxy"
#   addon_version = "v1.30.0-eksbuild.3"
#   #  resolve_conflicts_on_update = "PRESERVE"
# }

# resource "aws_eks_addon" "ebs-csi" {
#   cluster_name  = aws_eks_cluster.cluster.name
#   addon_name    = "aws-ebs-csi-driver"
#   addon_version = "v1.30.0-eksbuild.3"
#   #  resolve_conflicts_on_update = "PRESERVE"
# }

# resource "aws_eks_addon" "core-dns" {
#   cluster_name  = aws_eks_cluster.cluster.name
#   addon_name    = "coredns"
#   addon_version = "v1.11.1-eksbuild.9"
#   #  resolve_conflicts_on_update = "PRESERVE"
# }

////// VPC-CNI Role ///////////
# IAM Policy for VPC CNI Role
data "aws_iam_policy_document" "example_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace("${aws_eks_cluster.cluster.issuer}", "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.example.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "vpc_cni" {
  assume_role_policy = data.aws_iam_policy_document.example_assume_role_policy.json
  name               = "vpc-cni-role"
}

resource "aws_iam_role_policy_attachment" "example" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.vpc_cni.name
}

