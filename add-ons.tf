resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.18.2-eksbuild.1"
#  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.30.0-eksbuild.3"
#  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = "v1.30.0-eksbuild.3"
#  resolve_conflicts_on_update = "PRESERVE"
}

resource "aws_eks_addon" "core-dns" {
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "coredns"
  addon_version               = "v1.11.1-eksbuild.9"
#  resolve_conflicts_on_update = "PRESERVE"
}