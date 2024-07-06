resource "kubernetes_manifest" "karpenter_nodepool" {
  computed_fields = ["spec.requirements", "spec.limits"]
  manifest = yamldecode(file("${path.module}/karpenter_nodepool.yaml"))

  depends_on = [
    helm_release.karpenter,
    aws_eks_cluster.cluster
  ]
}

resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  manifest = yamldecode(file("${path.module}/karpenter_ec2nodeclass.yaml"))

  depends_on = [
    helm_release.karpenter,
    aws_eks_cluster.cluster
  ]
}
