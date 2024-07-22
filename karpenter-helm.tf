provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

# This data source can only be used in the us-east-1 region.
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}


resource "helm_release" "karpenter" {
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name //create resource
  repository_password = data.aws_ecrpublic_authorization_token.token.password  //create resource
  chart               = "karpenter"
  version             = "0.37.0" //update version
  wait                = false

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.nodes.arn
  }

  set {
    name  = "clusterName"
    value =  aws_eks_cluster.cluster.id
  }

  set {
    name  = "clusterEndpoint"
    value =  aws_eks_cluster.cluster.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }

  depends_on = [aws_eks_node_group.private-nodes]

}


locals {
  karpenter_provisioner_manifest = <<YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: default
  labels:
    app.kubernetes.io/app: Karpenter
spec:
  template:
    spec:
      nodeClassRef:
        name: default
      requirements:
        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values:  ["t2", "t3"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["2"]
        - key: "karpenter.k8s.aws/instance-hypervisor"
          operator: In
          values: ["nitro"]
  limits:
    cpu: 1000
  disruption:
    consolidationPolicy: WhenEmpty
    consolidateAfter: 30s
YAML

  krpenter_node_class_manifest = <<YAML
apiVersion: karpenter.sh/v1beta1
kind: EC2NodeClass
metadata:
  name: default
  labels:
    app.kubernetes.io/app: Karpenter
spec:
  amiFamily: AL2
  role: ${aws_iam_role.nodes.arn}
  subnetSelectorTerms:
    - tags:
       kubernetes.io/role/internal-elb: 1
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
  tags:
    karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
YAML

}

resource "kubernetes_manifest" "karpenter_provisioner" {
  manifest = yamldecode(local.karpenter_provisioner_manifest)
}

resource "kubernetes_manifest" "Karpenter_node_class" {
  manifest = yamldecode(local.krpenter_node_class_manifest)
}
