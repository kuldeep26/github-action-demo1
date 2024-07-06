# Creating a provisioner which will create additional nodes for unscheduled pods
resource "kubernetes_manifest" "karpenter_provisioner" {
  # Terraform by default doesn't tolerate values changing between configuration and apply results.
  # Users are required to declare these tolerable exceptions explicitly.
  # With a kubernetes_manifest resource, you can achieve this by using the computed_fields meta-attribute.
  computed_fields = ["spec.requirements", "spec.limits"]
  manifest = yamldecode(<<-EOF
    apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: default
spec:
  template:
    metadata:
      labels:
        intent: apps
    spec:
      nodeClassRef:
        name: default

      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["spot"]
        - key: karpenter.k8s.aws/instance-size
          operator: NotIn
          values: [nano, micro, small, medium, large]
  limits:
    cpu: 1000
    memory: 1000Gi
  disruption:
    consolidationPolicy: WhenEmpty
    consolidateAfter: 30s
---
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: default
spec:
  amiFamily: AL2
  subnetSelectorTerms:          
    - tags:
        karpenter.sh/discovery: "eksspotworkshop"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "eksspotworkshop"
  role: "Karpenter-eksspotworkshop"
  tags:
    Name: karpenter.sh/nodepool/default
    NodeType: "karpenter-workshop"
    IntentLabel: "apps"
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
    apiVersion: karpenter.sh/v1alpha5
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