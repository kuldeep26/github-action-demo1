resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "vpc-cni"
  addon_version = "v1.18.2-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}