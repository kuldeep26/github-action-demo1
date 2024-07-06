resource "kubernetes_manifest" "karpenter_nodepool" {
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
            - key: karpenter.k8s.aws/instance-family
              operator: In
              values: ["t2"]
            - key: karpenter.k8s.aws/instance-size
              operator: NotIn
              values: ["medium"]
      limits:
        cpu: 1000
        memory: 1000Gi
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
    EOF
  )

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubernetes_manifest" "karpenter_ec2nodeclass" {
  manifest = yamldecode(<<-EOF
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      subnetSelectorTerms:          
        - tags:
            karpenter.sh/discovery: "${aws_eks_cluster.cluster.name}"
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: "${aws_eks_cluster.cluster.name}"
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
