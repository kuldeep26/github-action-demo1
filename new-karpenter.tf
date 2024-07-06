# Creating a provisioner which will create additional nodes for unscheduled pods
resource "kubernetes_manifest" "karpenter_provisioner" {
  # Terraform by default doesn't tolerate values changing between configuration and apply results.
  # Users are required to declare these tolerable exceptions explicitly.
  # With a kubernetes_manifest resource, you can achieve this by using the computed_fields meta-attribute.
  computed_fields = ["spec.requirements", "spec.limits"]
  manifest = yamldecode(<<-EOF
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: default
    spec:
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values: ["t3"]
        - key: karpenter.k8s.aws/instance-size
          operator: In
          values: ["medium"]
      limits:
        resources:
          cpu: 1000
      providerRef:
        name: default
      ttlSecondsAfterEmpty: 30
  EOF
  )

  depends_on = [
    helm_release.karpenter
  ]
}

# Creating a Node template, which will be used for Node configuration in AWS side
resource "kubernetes_manifest" "karpenter_node_template" {
  # Terraform by default doesn't tolerate values changing between configuration and apply results.
  # Users are required to declare these tolerable exceptions explicitly.
  # With a kubernetes_manifest resource, you can achieve this by using the computed_fields meta-attribute.
  computed_fields = ["spec.requirements", "spec.limits"]
  manifest = yamldecode(<<-EOF
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      subnetSelector:
        karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
      securityGroupSelector:
        karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
      tags:
        karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
  EOF
  )

  depends_on = [
    helm_release.karpenter
  ]
}