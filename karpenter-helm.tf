provider "aws" {
  region = "us-east-1"
  alias  = "virginia"
}

# This data source can only be used in the us-east-1 region.
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.virginia
}

# resource "helm_release" "karpenter_crd" {
#   #  depends_on = [module.eks]
#   namespace = "kube-system"
#   #  create_namespace = true

#   name         = "karpenter-crd"
#   repository   = "oci://public.ecr.aws/karpenter"
#   chart        = "karpenter-crd"
#   version      = "v0.32.1"
#   replace      = true
#   force_update = true

# }

# Install Karpenter Helm chart
resource "helm_release" "karpenter" {
  depends_on = [
    aws_eks_node_group.private-nodes,
    kubernetes_service_account.karpenter_controller
  ]
  namespace           = "kube-system"
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart               = "karpenter"
  version             = "0.37.0"
  create_namespace    = true
  values = [
    <<-EOT
    serviceAccount:
      create: false
      name: karpenter-controller
      annotations:
        eks.amazonaws.com/role-arn: ${aws_iam_role.karpenter_controller.arn}
    settings:
      clusterName: ${aws_eks_cluster.cluster.name}
      clusterEndpoint: ${aws_eks_cluster.cluster.endpoint}
    EOT
  ]
}

# set {
#   name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#   value = aws_iam_role.karpenter_controller.arn
# }

# set {
#   name  = "settings.aws.clusterName"
#   value = aws_eks_cluster.cluster.name
# }

# set {
#   name  = "settings.aws.clusterEndpoint"
#   value = aws_eks_cluster.cluster.endpoint
# }

# set {
#   name  = "settings.aws.defaultInstanceProfile"
#   value = aws_iam_instance_profile.karpenter.name
# }

# Create Kubernetes Service Account
resource "kubernetes_service_account" "karpenter_controller" {
  metadata {
    name      = "karpenter-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"     = aws_iam_role.karpenter_controller.arn
      "meta.helm.sh/release-name"      = "karpenter"
      "meta.helm.sh/release-namespace" = "kube-system"
    }
  }
}




locals {
  karpenter_provisioner_manifest = <<YAML
apiVersion: karpenter.sh/v1
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

  karpenter_node_class_manifest = <<YAML
apiVersion: karpenter.k8s.aws/v1
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
       karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
  tags:
    karpenter.sh/discovery: ${aws_eks_cluster.cluster.name}
YAML
}

# resource "kubernetes_manifest" "karpenter_provisioner" {
#   manifest   = yamldecode(local.karpenter_provisioner_manifest)
#   depends_on = [helm_release.karpenter]
# }

# resource "kubernetes_manifest" "karpenter_node_class" {
#   manifest   = yamldecode(local.karpenter_node_class_manifest)
#   depends_on = [helm_release.karpenter]
# }
