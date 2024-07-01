resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "vpc-cni"
  addon_version = "v1.18.2-eksbuild.1"
  #  resolve_conflicts_on_update = "PRESERVE"
  service_account_role_arn = aws_iam_role.vpc_cni_role.arn
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "kube-proxy"
  addon_version = "v1.30.0-eksbuild.3"
  #  resolve_conflicts_on_update = "PRESERVE"
}

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
resource "aws_iam_role_policy_attachment" "vpc_cni_policy_attachment" {
  role       = aws_iam_role.vpc_cni_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# IAM Role for VPC CNI Add-on
resource "aws_iam_role" "vpc_cni_role" {
  name = "vpc-cni-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

