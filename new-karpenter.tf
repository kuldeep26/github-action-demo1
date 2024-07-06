resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
      tags:
        karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["t2", "t3"]
            # - key: "karpenter.k8s.aws/instance-cpu"
            #   operator: In
            #   values: ["2"]
            # - key: "karpenter.k8s.aws/instance-hypervisor"
            #   operator: In
            #   values: ["nitro"]
            # - key: "karpenter.k8s.aws/instance-generation"
            #   operator: Gt
            #   values: ["2"]
            - key : "karpenter.k8s.aws/instance-size",
              operator : "In",
              values : ["medium"]
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}
